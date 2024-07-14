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

    address public rustContractAddress;

    address public deployer;

    constructor(address _rustContractAddress, PoolSwapTest _swapRouter, address hook) {
        rustContractAddress = _rustContractAddress;
        deployer = msg.sender;
        swapRouter = _swapRouter;
        entryPointHook = hook;
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

        // Assuming a matching event should be emitted, however, this may require additional logic to capture matched orders
        // emit OrderMatched(buyOrderId, sellOrderId, buyer, seller, amount, price);
    }

    function getOrdersLength() external view override returns (uint256) {
        (bool success, bytes memory data) = rustContractAddress.staticcall(
            abi.encodeWithSignature("getOrdersLength()")
        );

        require(success, "Failed to get orders length");

        return abi.decode(data, (uint256));
    }
}