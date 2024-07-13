pragma solidity ^0.8.25;

import "../interfaces/IOrderMatcher.sol";
import "../EntryPoint.sol";

contract OrderPlacerMock is IOrderMatcher {

    EntryPoint public hook;

    constructor(){}

    function placeLimitOrder(OrderType orderType, address token0, address token1, uint256 amount, uint256 price) external returns (uint256){

    }

    function retrieveLimitOrder(uint256 index) external view returns (Order memory){

    }

    function cancelLimitOrder(uint256 orderId) external{

    }

    function cancelAllLimitOrders() external{

    }

    function placeMarketOrder(OrderType orderType, address token0, address token1, uint256 amount) external{
        address tokenToSend;
        if(orderType == OrderType.SELL) {
            tokenToSend = token0;
        } else {
            tokenToSend = token1;
        }
        hook.sendTokens(amount, tokenToSend, address(0));
    }

    function setHook(EntryPoint _hook) external {
        hook = _hook;
    }
}