// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/OrderPlacerProxy.sol";

contract OrderPlacerProxyScript is Script {

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        address _endpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f; 
        address _owner = msg.sender; 
        address _rustContractAddress = 0x21b30048a9c0a39ec48c199eb0728a1dd80cbecd;
        OrderPlacerProxy orderPlacer = new OrderPlacerProxy(_endpoint, _owner, _rustContractAddress);
        vm.stopBroadcast();
    }
}
