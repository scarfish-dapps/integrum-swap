// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";

/// @title IOrderMatcher
/// @notice Interface for the OrderMatcher contract
interface IOrderMatcher {
 
    /// @notice Struct representing an order
    struct Order {
        uint256 id;
        address user;
        OrderType orderType;
        address token0;
        address token1;
        uint256 amount;
        uint256 price; // for limit orders
        bool isFilled;
        bool isCanceled;
    }

    /// @notice Enum representing the type of order
    enum OrderType { BUY, SELL }

    /// @notice Event emitted when an order is placed
    event OrderPlaced(uint256 orderId, address indexed user, OrderType orderType, address token0, address token1, uint256 amount, uint256 price);

    /// @notice Event emitted when an order is canceled
    event OrderCanceled(uint256 orderId, address indexed user);

    /// @notice Event emitted when all orders are canceled for a user
    event AllOrdersCanceled(address indexed user);

    /// @notice Event emitted when two orders are matched
    event OrderMatched(uint256 buyOrderId, uint256 sellOrderId, address indexed buyer, address indexed seller, uint256 amount, uint256 price);

    function placeLimitOrder(OrderType orderType, address token0, address token1, uint256 amount, uint256 price) external returns (uint256);

    function retrieveLimitOrder(uint256 index) external view returns (Order memory);

    function cancelLimitOrder(uint256 orderId) external;

    function cancelAllLimitOrders() external;

    function placeMarketOrder(OrderType orderType, address token0, address token1, uint256 amount) external;
}