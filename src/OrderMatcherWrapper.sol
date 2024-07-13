// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IOrderMatcherWrapper} from "./IOrderMatcherWrapper.sol";
import {OApp, Origin, MessagingFee } from "lib/LayerZero-v2/packages/layerzero-v2/evm/oapp/contracts/oapp/OApp.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract OrderMatcherWrapper is OApp, IOrderMatcherWrapper {
    address public rustContractAddress;

    address public deployer;

    bool public inWrapper = false; 
    bool public setTrue = false;
    uint32 public callSenderEid = 1;

    constructor(address _endpoint, address _owner, address _rustContractAddress) OApp(_endpoint, _owner) Ownable(_owner)  {
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
        uint256 price,
        address user,
        uint32 userEid
    ) public payable  {
            setTrue = true;

        (bool success, bytes memory data) = rustContractAddress.call(
            abi.encodeWithSignature(
                "placeLimitOrder(address,uint256,uint256,address,address,uint256,uint256)",
                user,
                uint256(userEid),
                orderType,
                token0,
                token1,
                amount,
                price
            )
        );  
        require(success, "Failed to place limit order");


        // Decode the returned data 
    (
        uint256 orderId,
        address user,
        uint256 otherUserEid,
        address otherUser,
        int256 amountToken0DeltaUser,
        int256 amountToken1DeltaUser,
        int256 amountToken0DeltaOtherUser,
        int256 amountToken1DeltaOtherUser,
        address otherToken0,
        address otherToken1
    ) = abi.decode(data, (uint256, address, uint256, address, int256, int256, int256, int256, address, address));
        uint32 otherUserEidB32 = uint32(otherUserEid);



        // to do
        // send a message back to the main contract
    
        // if(otherUser != address(0)){
        //     if(orderType == 0){   // if buy
        //     //_lzSend user
        //     // step 1 first for USER
        //     // tokens1  (burn)
        //     // tokens0  (mint)
        //     // send for user 
        //     // bytes memory _payloadUser = abi.encode(token0, token1, amountToken0DeltaUser, amountToken1DeltaUser);
        //     // _lzSend(
        //     //     userEid,
        //     //     _payloadUser,
        //     //     "", // Options can be empty or configured as needed
        //     //     MessagingFee(msg.value, 0),
        //     //     payable(user)
        //     // );
        //     // //_lzSend otherUser
        //     // // step 2   otherUser
        //     // // tokens0   (burn)
        //     // // tokens1  (mint)
        //     // // send for otherUser 
        //     // bytes memory _payloadOtherUser = abi.encode(otherToken0, otherToken1, amountToken0DeltaOtherUser, amountToken1DeltaOtherUser);
        //     // _lzSend(
        //     //     otherUserEidB32,
        //     //     _payloadOtherUser,
        //     //     "", // Options can be empty or configured as needed
        //     //     MessagingFee(msg.value, 0),
        //     //     payable(user)
        //     // );
                
        //     } 
        //     else {  // if sell  

        //         //_lzSend user
        //         // tokens0  (burn)
        //         // tokens1  (mint)

        //         //_lzSend otherUser                
        //         // tokens1 (burn)
        //         // tokens0  (mint)

        //     }
        // }

    }

    function retrieveLimitOrder(uint256 index) public view returns (Order memory) {
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

    function cancelLimitOrder(uint256 orderId) public {
        (bool success,) = rustContractAddress.call(
            abi.encodeWithSignature("cancelLimitOrder(uint256)", orderId)
        );

        require(success, "Failed to cancel limit order");

        emit OrderCanceled(orderId, msg.sender);
    }

    function cancelAllLimitOrders() public {
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
    ) public  {
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


 function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata payload,
        address,  // Executor address as specified by the OApp.
        bytes calldata  // Any extra data or options to trigger on receipt.
    ) internal override {
        // Decode the payload
        // adaugat campuri pentru restul (limitOrderID etc)
        (
            address sender,
            uint256 orderType,
            string memory orderFunctionType,
            address token0,
            address token1,
            uint256 amount,
            uint256 price
        ) = abi.decode(payload, (address, uint256, string, address, address, uint256, uint256));
        // Extract the sender's EID from the origin
        // we need the id on the orderMatcherWrapper so we know where the message is from
        uint32 senderEid = _origin.srcEid;
        bytes32 call_sender = _origin.sender;
        inWrapper = true;
        callSenderEid = senderEid;

        if(keccak256(abi.encodePacked(orderFunctionType)) == keccak256(abi.encodePacked("LIMIT_ORDER"))){
            this.placeLimitOrder(orderType,token0,token1,amount,price,sender, senderEid);

        }else if(keccak256(abi.encodePacked(orderFunctionType))  == keccak256(abi.encodePacked("CANCEL_ORDER"))){
                // cancellALl
        }else if(keccak256(abi.encodePacked(orderFunctionType)) ==  keccak256(abi.encodePacked("CANCEL_ALL_ORDER"))){
            
        }else if(keccak256(abi.encodePacked(orderFunctionType)) ==  keccak256(abi.encodePacked("MARKET_ORDER"))){

        }else{
            revert("wrong order");
        }


        // Extract the sender's EID from the origin
        // uint32 senderEid = _origin.srcEid;
        // bytes32 sender = _origin.sender;
        // Emit the event with the decoded message and sender's EID
        // emit MessageReceived(data, senderEid, sender);
    }

    function getChainID() external view returns (uint256) {
        return block.chainid;
    }
}
