// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOrderMatcher} from "./IOrderMatcher.sol";
import {OrderPlacerProxy} from "./OrderPlacerProxy.sol";
import {OApp, Origin, MessagingFee } from "lib/LayerZero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/OApp.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";
import { OFTContract } from "./OFTContract.sol";

import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/// Routes limit orders to the OrderPlacerProxy and market orders to the UniswapV4Router
contract MainContract is IOrderMatcher, OApp {

    address public rustContractAddress;

    address public deployer;

    OrderPlacerProxy public orderPlacerProxy;

    uint32 public eid;

    uint32 public eidSender;

    //on Sepolia -> set OptimismSepolia
    //on OptimismSepolia ->set Sepolia
    mapping(uint32 eid => address Blockchain) connections;

    constructor(address _endpoint, address _orderPlacerProxy, address _owner) OApp(_endpoint, _owner) Ownable(_owner){
        orderPlacerProxy = OrderPlacerProxy(_orderPlacerProxy);
        deployer = msg.sender;
    }

    function setRustContractAddress(address _rustContractAddress) external {
        require(msg.sender == deployer, "Only deployer can set the Rust contract address");
        rustContractAddress = _rustContractAddress;
    }


    function setOrderPlacerProxy(address _orderPlacerProxy) external {
        require(msg.sender == deployer, "Only deployer can set the orderPlacerProxy");
        orderPlacerProxy= OrderPlacerProxy(_orderPlacerProxy);
    }

    function setBlockchain(uint32 _eid, address blockchain) public {
        require(msg.sender == deployer, "na na na");
        connections[_eid] = blockchain;
    }

    /// @inheritdoc IOrderMatcher
    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price, bytes memory _orders) external payable override 
    returns (OrderResponse memory) {

        address sender = msg.sender;
        uint256 eid = 0;

        orderPlacerProxy.placeLimitOrder{value: msg.value}(orderType, token0, token1, amount, price, sender, _orders);
        
        //////////////////////////////////////////////////////////////////
        OFTContract(token0).approve(address(this), amount);

        bytes memory _payload = abi.encode(orderType, token0, token1, amount, price);
            _lzSend(
                eidSender,
                _payload,
                _orders,
                // Fee in native gas and ZRO token.
                MessagingFee(msg.value, 0),
                // Refund address in case of failed source message.
                payable(sender) 
            );
        //////////////////////////////////////////////////////////////////

        // OFTContract(token0).approve(address(this), amount);
        // OFTContract(token0).send();

        (   uint256 orderId,
            address user,
            address otherUser,  
            int256 amountToken0DeltaUser,
            int256 amountToken1DeltaUser,
            int256 amountToken0DeltaOtherUser,
            int256 amountToken1DeltaOtherUser
            ) = (1,sender,sender,100,200,300,400);

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

    mapping(address user => mapping(OFTContract token => uint256 amount)) balances;

    function executeOrder(uint256 orderType,  address token0, address token1, uint256 amount, uint256 price, bytes memory _orders) external {
        if(orderType == 0){//buy 
            //stake token1
            stake(OFTContract(token1), amount);
            //release token0
            release(OFTContract(token0), amount * price);
        }
        else if (orderType == 1){
            //stake token0
            stake(OFTContract(token0), amount * price);
            //release token1
            release(OFTContract(token1), amount);
        }
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address,  // Executor address as specified by the OApp.
        bytes calldata  // Any extra data or options to trigger on receipt.
    ) internal override {
        // Decode the payload to get the message
        // data = abi.decode(payload, (string));
        // Extract the sender's EID from the origin
        uint32 senderEid = _origin.srcEid;
        bytes32 sender = _origin.sender;
        (   uint256 orderType,
            address token0,
            address token1,
            int256 amountToken0DeltaUser,
            int256 amountToken1DeltaUser
        ) = abi.decode(payload, (uint256, address, address, int256, int256));
        

        // Emit the event with the decoded message and sender's EID
        // emit MessageReceived(data, senderEid, sender);
    }

    /////Providing liquidity/////

    function stake(OFTContract token, uint256 value) public {
        OFTContract(token).approve(address(this), value);
        OFTContract(token).transferFrom(msg.sender, address(this), value);
        balances[msg.sender][token] += value;
    }

    function release(OFTContract token, uint256 value) public {
        OFTContract(token).transfer(msg.sender, value);
        balances[msg.sender][token] -= value;
    }

    function placeLimitOrder2(uint256 orderType, address token0, address token1, uint256 amount, uint256 price, bytes memory _orders) external payable  
    {

        address sender = msg.sender;
        uint256 eid = 0;

        orderPlacerProxy.placeLimitOrder{value: msg.value}(orderType, token0, token1, amount, price, sender, _orders);

    }

    function placeLimitOrder3(uint256 orderType, address token0, address token1, uint256 amount, uint256 price) external payable  
    {

        address sender = msg.sender;
        uint256 eid = 0;

        orderPlacerProxy.placeLimitOrder{value: msg.value}(orderType, token0, token1, amount, price, sender,"0x0003010011010000000000000000000000000000ea60");

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
        uint256 eids = 0;

        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                //user: Address, _eid: U256, order_type: U256, token0: Address, token1: Address, mut amount: U256
                "placeMarketOrder(address,uint256,uint256,address,address,uint256)",
                sender,
                eids,
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
