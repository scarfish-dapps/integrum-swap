// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/// @title IOrderMatcher
/// @notice Interface for the OrderMatcher contract
interface IOrderMatcher {
 
    /// @notice Struct representing an order
    struct Order {
        uint256 id;
        address user;
        uint256 orderType;
        address token0;
        address token1;
        uint256 amount;
        uint256 price; // for limit orders
        bool isFilled;
        bool isCanceled;
    }

    struct OrderResponse {
        uint256 orderId; 
        address user;
        address other_users; 
        int256 amount_token0_delta_user; 
        int256 amount_token1_delta_user; 
        int256 amount_token0_delta_other_users; 
        int256 amount_token1_delta_other_users;
    }

    enum OrderType { BUY, SELL }

    /// @notice Event emitted when an order is placed
    event OrderPlaced(uint256 orderId, address indexed user, uint256 orderType, address token0, address token1, uint256 amount, uint256 price);

    /// @notice Event emitted when an order is canceled
    event OrderCanceled(uint256 orderId, address indexed user);

    /// @notice Event emitted when all orders are canceled for a user
    event AllOrdersCanceled(address indexed user);

    /// @notice Event emitted when two orders are matched
    event OrderMatched(uint256 buyOrderId, uint256 sellOrderId, address indexed buyer, address indexed seller, uint256 amount, uint256 price);

    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price) external 
    returns (OrderResponse memory);

    function retrieveLimitOrder(uint256 index) external view returns (Order memory);

    function cancelLimitOrder(uint256 orderId) external;

    function cancelAllLimitOrders() external;

    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount) external;
}