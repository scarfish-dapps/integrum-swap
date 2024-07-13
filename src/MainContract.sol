// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOrderMatcher} from "./IOrderMatcher.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

/// Routes limit orders to the OrderPlacerProxy and market orders to the UniswapV4Router
contract MainContract is IOrderMatcher {
    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_PRICE + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_PRICE - 1;

    PoolSwapTest public swapRouter;
    address entryPointHook;

    constructor(PoolSwapTest _swapRouter, address hook) {
        swapRouter = _swapRouter;
        entryPointHook = hook;
    }

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
    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount) external {
        bool zeroForOne = (orderType == 1) ? true : false;

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