// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./IOrderMatcher.sol";


contract OrderMatcherWrapper is IOrderMatcher {
    address public rustContractAddress;

    address public deployer;

    constructor(address _rustContractAddress) {
        rustContractAddress = _rustContractAddress;
        deployer = msg.sender;
    }

    function setRustContractAddress(address _rustContractAddress) external {
        require(msg.sender == deployer, "Only deployer can set the Rust contract address");
        rustContractAddress = _rustContractAddress;
    }

    function placeLimitOrder(
        uint256 orderType,
        address token0,
        address token1,
        uint256 amount,
        uint256 price
    ) external override returns (OrderResponse memory) {

        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                "placeLimitOrder(uint256,address,address,uint256,uint256)",
                orderType,
                token0,
                token1,
                amount,
                price
            )
        );

        require(success, "Failed to place limit order");

        (uint256 orderId, address user, address otherUser, int256 amountToken0DeltaUser, int256 amountToken1DeltaUser, int256 amountToken0DeltaOtherUser, int256 amountToken1DeltaOtherUser) = 
        abi.decode(data, (uint256, address, address, int256, int256, int256, int256));

        // emit OrderPlaced(orderId, msg.sender, orderType, token0, token1, amount, price);

        return OrderResponse({
            orderId: orderId,
            user: user,
            other_users: otherUser,
            amount_token0_delta_user: amountToken0DeltaUser,
            amount_token1_delta_user: amountToken1DeltaUser,
            amount_token0_delta_other_users: amountToken0DeltaOtherUser,
            amount_token1_delta_other_users: amountToken1DeltaOtherUser
        });
    }

    function retrieveLimitOrder(uint256 index) external view override returns (Order memory) {
        (bool success, bytes memory data) = rustContractAddress.staticcall(
            abi.encodeWithSignature("retrieveLimitOrder(uint256)", index)
        );

        require(success, "Failed to retrieve limit order");

        (uint256 id, address user, uint256 orderType, address token0, address token1, uint256 amount, uint256 filledAmount, uint256 price, bool isFilled, bool isCanceled) = abi.decode(data, (uint256, address, uint256, address, address, uint256, uint256, uint256, bool, bool));

        Order memory order = Order({
            id: id,
            user: user,
            orderType: orderType,
            token0: token0,
            token1: token1,
            amount: amount,
            price: price,
            isFilled: isFilled,
            isCanceled: isCanceled
        });

        return order;
    }

    function cancelLimitOrder(uint256 orderId) external override {
        (bool success,) = rustContractAddress.call(
            abi.encodeWithSignature("cancelLimitOrder(uint256)", orderId)
        );

        require(success, "Failed to cancel limit order");

        emit OrderCanceled(orderId, msg.sender);
    }

    function cancelAllLimitOrders() external override {
        (bool success,) = rustContractAddress.call(
            abi.encodeWithSignature("cancelAllLimitOrders()")
        );

        require(success, "Failed to cancel all limit orders");

        emit AllOrdersCanceled(msg.sender);
    }

    function placeMarketOrder(
        uint256 orderType,
        address token0,
        address token1,
        uint256 amount
    ) external override {
        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                "placeMarketOrder(uint256,address,address,uint256)",
                uint256(orderType),
                token0,
                token1,
                amount
            )
        );

        require(success, "Failed to place market order");

        (address user, address otherUsers, int256 amountToken0DeltaUser, int256 amountToken1DeltaUser, int256 amountToken0DeltaOtherUsers, int256 amountToken1DeltaOtherUsers) = 
        abi.decode(data, (address, address, int256, int256, int256, int256));

        // Assuming a matching event should be emitted, however, this may require additional logic to capture matched orders
        // emit OrderMatched(buyOrderId, sellOrderId, buyer, seller, amount, price);
    }
}
