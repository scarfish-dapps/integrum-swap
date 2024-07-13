// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOrderMatcher} from "./IOrderMatcher.sol";

/// Proxies calls to the OrderMatcher contract via LayerZero
contract OrderPlacerProxy is IOrderMatcher {

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
    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount) external override {
    }
}
