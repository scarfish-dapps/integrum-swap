// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";

contract DeployPoolScript is Script {
    bytes constant ZERO_BYTES = Constants.ZERO_BYTES;

    uint160 constant SQRT_PRICE_1_1 = Constants.SQRT_PRICE_1_1;

    // set the PoolManager address
    IPoolManager constant POOLMANAGER = IPoolManager(0x75E7c1Fd26DeFf28C7d1e82564ad5c24ca10dB14);

    IHooks constant hook = IHooks(0x0DC1B581e91C13Fcb9e0d7135A47cC2a64f20088);

    Currency constant currency0 = Currency.wrap(0x0000000000000000000000000000000000000000);

    Currency constant currency1 = Currency.wrap(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    function setUp() public {}

    function run() public {


        PoolKey memory key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));

        vm.broadcast();

        POOLMANAGER.initialize(key, SQRT_PRICE_1_1, ZERO_BYTES);
    }
}