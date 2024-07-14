// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {BaseHook} from "v4-periphery/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {toBeforeSwapDelta, BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {IOrderMatcher} from "./IOrderMatcher.sol";
import {SafeCast} from "v4-core/src/libraries/SafeCast.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

contract EntryPoint is BaseHook {
    using PoolIdLibrary for PoolKey;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using SafeCast for *;

    struct InternalOrder {
        uint256 orderType;
        address token0;
        address token1;
        uint256 amount;
        bool executed;
    }

    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_PRICE + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_PRICE - 1;

    IOrderMatcher public orderPlacer;

    PoolSwapTest public swapRouter;

    bytes internal constant ZERO_BYTES = bytes("");

    mapping(address => mapping(uint256 => InternalOrder)) public internalOrder;

    mapping(address => uint256) public orderNonce;

    constructor(IPoolManager _poolManager, IOrderMatcher _orderPlacer, PoolSwapTest _swapRouter) BaseHook(_poolManager) {
        orderPlacer =_orderPlacer;
        swapRouter = _swapRouter;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: true,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------

    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params, 
        bytes calldata hookData 
    )
        external
        override
        returns (bytes4, BeforeSwapDelta beforeSwapDelta, uint24)
    {
        if(keccak256(hookData) != keccak256(ZERO_BYTES) && hookData.length > 64) {
            Currency input = params.zeroForOne ? key.currency0 : key.currency1;
            poolManager.take(input, address(this), uint256(-params.amountSpecified));

            placeMarketAndInternalOrder(hookData);
            return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(-int128(params.amountSpecified), 0), 0);
        }

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function sendTokens(address sender, uint256 nonce, address destination) external {
        require(msg.sender == address(orderPlacer), "CALLER IS NOT ORDERPLACER");

        InternalOrder storage order = internalOrder[sender][nonce];

        address tokenToSend;
        if(order.orderType == 1) {
            tokenToSend = order.token0;
        } else {
            tokenToSend = order.token1;
        }

        order.executed  = true;

        IERC20(tokenToSend).transfer(destination, order.amount);
    }

    function executeInternalOrder(address sender, uint256 nonce) external{
        require(msg.sender == address(orderPlacer), "CALLER IS NOT ORDERPLACER");
        InternalOrder storage order = internalOrder[sender][nonce];
        require(order.executed == false, "Order has been executed");

        bool zeroForOne = (order.orderType == 1) ? true : false;

        address tokenToSend;
        if(order.orderType == 1) {
            tokenToSend = order.token0;
        } else {
            tokenToSend = order.token1;
        }
        IERC20(tokenToSend).transfer(sender, order.amount);

       swapRouter.swap(
            PoolKey({
                currency0: Currency.wrap(order.token0),
                currency1: Currency.wrap(order.token1),
                fee: 3000,
                tickSpacing: 60,
                hooks: IHooks(address(this))
            }),
            IPoolManager.SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(order.amount),
                sqrtPriceLimitX96: zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            abi.encode(sender)
        );

        order.executed = true;
    }

    function placeMarketAndInternalOrder(bytes calldata hookData) internal {
            (
                address user,
                uint256 orderType,
                address token0,
                address token1,
                uint256 amount
            ) = abi.decode(hookData, (address, uint256, address, address, uint256));


            placeInternalOrder(user, orderType, token0, token1, amount);
            orderPlacer.placeMarketOrder(orderType, token0, token1, amount);
    }

    function placeInternalOrder(
        address user,
        uint256 orderType,
        address token0,
        address token1,
        uint256 amount
    ) internal {
        uint256 currentNonce = orderNonce[user];

        internalOrder[user][currentNonce] = InternalOrder({
            orderType: orderType,
            token0: token0,
            token1: token1,
            amount: amount,
            executed: false
        });

        orderNonce[user] += 1;
    }
}