pragma solidity ^0.8.25;

import {IOrderMatcher} from "./interfaces/IOrderMatcher.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

contract MainContract is IOrderMatcher {

    /// @inheritdoc IOrderMatcher
    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price) external override 
    returns (OrderResponse memory) {
        return OrderResponse(0, address(0), address(0), 0, 0, int256(0), int256(0));
    }

    /// @inheritdoc IOrderMatcher
    function retrieveLimitOrder(uint256 index) external view override returns (Order memory) {
        return Order(0, address(0), uint256(0), address(0), address(0), 0, 0, false, false);
    }

    /// @inheritdoc IOrderMatcher
    function cancelLimitOrder(uint256 orderId) external override {
    }

    /// @inheritdoc IOrderMatcher
    function cancelAllLimitOrders() external override {
    }

    /// @inheritdoc IOrderMatcher
    function placeMarketOrder(OrderType orderType, address token0, address token1, uint256 amount) external {
        bool zeroForOne = (orderType == IOrderMatcher.OrderType.SELL) ? true : false;

        swapRouter.swap(
            PoolKey({
                currency0: Currency.wrap(token0),
                currency1: Currency.wrap(token1),
                fee: 3000,
                tickSpacing: 60,
                hooks: IHooks(entryPointHook)
            }),
            IPoolManager.SwapParams({
                zeroForOne: zeroForOne,
                amountSpecified: -int256(amount),
                sqrtPriceLimitX96: zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            abi.encode(
                msg.sender,
                orderType,
                token0,
                token1,
                amount
            )
        );
    }
}
