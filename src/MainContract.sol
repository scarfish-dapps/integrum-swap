// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOrderMatcher} from "./IOrderMatcher.sol";

/// Routes limit orders to the OrderPlacerProxy and market orders to the UniswapV4Router
contract MainContract is IOrderMatcher {

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

    /// @inheritdoc IOrderMatcher
    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price) external override 
    returns (OrderResponse memory) {

        address sender = msg.sender;
        uint256 eid = 0;
        //(&mut self, user: Address, eid: U256, order_type: U256, token0: Address, token1: Address, mut amount: U256, price: U256)
        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                "placeLimitOrder(address,uint256,uint256,address,address,uint256,uint256)",
                sender,
                eid,
                orderType,
                token0,
                token1,
                amount,
                price
            )
        );

        require(success, "Failed to place limit order");


        //(orders_length,         user,         other_eid,       other_user,      amount_token0_delta_user,     amount_token1_delta_user,    amount_token0_delta_other_user,   amount_token1_delta_other_user,         other_token0,        other_token1)
        (uint256 orderId, address user, uint256 other_eid, address otherUser, int256 amountToken0DeltaUser, int256 amountToken1DeltaUser, int256 amountToken0DeltaOtherUser, int256 amountToken1DeltaOtherUser, address otherToken0, address otherToken1) = 
        abi.decode(data, (uint256, address, uint256, address, int256, int256, int256, int256, address, address));

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

    /// @inheritdoc IOrderMatcher
    function retrieveLimitOrder(uint256 index) external view override returns (Order memory) {
        
        (bool success, bytes memory data) = rustContractAddress.staticcall(
            abi.encodeWithSignature("retrieveLimitOrder(uint256)", index)
        );

        require(success, "Failed to retrieve limit order");
        
        (uint256 id, address user, uint256 eid, uint256 orderType, address token0, address token1, uint256 amount, uint256 filledAmount, uint256 price, bool isFilled, bool isCanceled) = 
        abi.decode(data, (uint256, address, uint256, uint256, address, address, uint256, uint256, uint256, bool, bool));

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

    /// @inheritdoc IOrderMatcher
    function cancelLimitOrder(uint256 orderId) external override {
        (bool success,) = rustContractAddress.call(
            abi.encodeWithSignature("cancelLimitOrder(uint256)", orderId)
        );

        require(success, "Failed to cancel limit order");

        emit OrderCanceled(orderId, msg.sender);
    }

    /// @inheritdoc IOrderMatcher
    function cancelAllLimitOrders() external override {
        (bool success,) = rustContractAddress.call(
            abi.encodeWithSignature("cancelAllLimitOrders()")
        );

        require(success, "Failed to cancel all limit orders");

        emit AllOrdersCanceled(msg.sender);
    }

    /// @inheritdoc IOrderMatcher
    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount) external override {
        address sender = msg.sender;
        uint256 eid = 0;

        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                //user: Address, _eid: U256, order_type: U256, token0: Address, token1: Address, mut amount: U256
                "placeMarketOrder(address,uint256,uint256,address,address,uint256)",
                sender,
                eid,
                uint256(orderType),
                token0,
                token1,
                amount
            )
        );

        require(success, "Failed to place market order");

        //(      user,         other_eid, other_user, amount_token0_delta_user, amount_token1_delta_user, amount_token0_delta_other_user, amount_token1_delta_other_user, other_token0, other_token1)
        (address user, uint256 other_eid, address otherUsers, int256 amountToken0DeltaUser, int256 amountToken1DeltaUser, int256 amountToken0DeltaOtherUsers, int256 amountToken1DeltaOtherUsers, address otherToken0, address otherToken1) = 
        abi.decode(data, (address, uint256, address, int256, int256, int256, int256, address, address));

        // Assuming a matching event should be emitted, however, this may require additional logic to capture matched orders
        // emit OrderMatched(buyOrderId, sellOrderId, buyer, seller, amount, price);
    }
}
