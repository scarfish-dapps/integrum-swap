pragma solidity ^0.8.25;

interface IEntryPointMinimal {
    function sendTokens(uint256 amount, address token, address destination) external;

    function orderPlacer() external view returns(address);
}