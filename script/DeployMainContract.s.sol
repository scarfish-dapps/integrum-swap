// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {MainContract} from "../src/MainContract.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

contract DeployMainContract is Script {

    IHooks constant hook = IHooks(0x0DC1B581e91C13Fcb9e0d7135A47cC2a64f20088);

    PoolSwapTest constant swapRouter = PoolSwapTest(0x82438Ae8A7a17b276C98954873f1029dFDBfEa20);

    function setUp() public {}

    function run() public {

        vm.broadcast();

        MainContract mainContract = new MainContract(swapRouter, address(hook));
    }
}