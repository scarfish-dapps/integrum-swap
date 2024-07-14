pragma solidity ^0.8.25;

import "../IOrderMatcher.sol";
import "../EntryPoint.sol";

contract OrderPlacerMock is IOrderMatcher {

    EntryPoint public hook;

    constructor(){}

    function placeLimitOrder(uint256 orderType, address token0, address token1, uint256 amount, uint256 price) external returns (OrderResponse memory){

    }

    function retrieveLimitOrder(uint256 index) external view returns (Order memory){

    }

    function cancelLimitOrder(uint256 orderId) external{

    }

    function cancelAllLimitOrders() external{

    }

    function placeMarketOrder(uint256 orderType, address token0, address token1, uint256 amount) external{
        
    }

    function executeInternalOrder(address sender, uint256 nonce) external {
         hook.executeInternalOrder(sender, nonce);
    }

    function fulfillCallback(address sender, uint256 nonce, address dest) external {
        // address tokenToSend;
        // if(orderType == 1) {
        //     tokenToSend = token0;
        // } else {
        //     tokenToSend = token1;
        // }
        hook.sendTokens(sender, nonce, dest);
    }

    function setHook(EntryPoint _hook) external {
        hook = _hook;
    }

    function getOrdersLength() external view returns (uint256){
        
    }
}