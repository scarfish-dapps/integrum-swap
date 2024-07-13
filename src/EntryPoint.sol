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

contract EntryPoint is BaseHook {
    using PoolIdLibrary for PoolKey;
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using SafeCast for *;

    IOrderMatcher orderPlacer;

    bytes internal constant ZERO_BYTES = bytes("");

    constructor(IPoolManager _poolManager, IOrderMatcher _orderPlacer) BaseHook(_poolManager) {
        orderPlacer =_orderPlacer;
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
        if(keccak256(hookData) != keccak256(ZERO_BYTES)) {
            Currency input = params.zeroForOne ? key.currency0 : key.currency1;
            poolManager.take(input, address(this), uint256(-params.amountSpecified));

            placeMarketAndInternalOrder(hookData);
            return (BaseHook.beforeSwap.selector, toBeforeSwapDelta(-int128(params.amountSpecified), 0), 0);
        }

        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function sendTokens(uint256 amount, address token, address destination) external {
        require(msg.sender == address(orderPlacer), "CALLER IS NOT ORDERPLACER");

        IERC20(token).transfer(destination, amount);
    }

    function executeInternalOrder(bytes calldata orderData) external {
        require(msg.sender == address(orderPlacer), "CALLER IS NOT ORDERPLACER");
    }

    function externalPrice() internal view returns(uint256 extPrice) {
        return 1;
    }

    function internalPrice() internal view returns(uint256 intPrice) {

    }

    function placeMarketAndInternalOrder(bytes calldata hookData) internal {
            (
                address user,
                uint256 orderType,
                address token0,
                address token1,
                uint256 amount
            ) = abi.decode(hookData, (address, uint256, address, address, uint256));


            placeInternalOrder();
            orderPlacer.placeMarketOrder(orderType, token0, token1, amount);
    }

    function placeInternalOrder() internal {

    }
}