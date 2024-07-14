// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import {IOrderMatcher} from "../src/IOrderMatcher.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";

contract CounterScript is Script {
    // deployer proxy used by foundry scripts
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    
    // set the PoolManager address
    address constant POOLMANAGER = address(0x75E7c1Fd26DeFf28C7d1e82564ad5c24ca10dB14);

    address constant orderPlacerProxy = address(0x98f23A2079b563A810c05bF464Ace378561b35B3);

    PoolSwapTest constant swapRouter = PoolSwapTest(0x82438Ae8A7a17b276C98954873f1029dFDBfEa20);
    function setUp() public {}

    function run() public {
        // set the hook permissions
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
        );

        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, type(EntryPoint).creationCode, abi.encode(address(POOLMANAGER), address(orderPlacerProxy), address(swapRouter)));

        // Deploy the hook using CREATE2
        vm.broadcast();
        EntryPoint entryPoint = new EntryPoint{salt: salt}(IPoolManager(POOLMANAGER), IOrderMatcher(orderPlacerProxy), swapRouter);
        require(address(entryPoint) == hookAddress, "CounterScript: hook address mismatch");
    }
}