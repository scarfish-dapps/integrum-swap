// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {PoolModifyLiquidityTest} from "v4-core/src/test/PoolModifyLiquidityTest.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {MainContract} from "../src/MainContract.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {MainContract} from "../src/MainContract.sol";

contract SwapScript is Script {
    bytes constant ZERO_BYTES = Constants.ZERO_BYTES;

    uint160 constant SQRT_PRICE_1_1 = Constants.SQRT_PRICE_1_1;

    IHooks constant hook = IHooks(0x0DC1B581e91C13Fcb9e0d7135A47cC2a64f20088);

    Currency constant currency0 = Currency.wrap(0x0000000000000000000000000000000000000000);

    Currency constant currency1 = Currency.wrap(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    PoolSwapTest constant swapRouter = PoolSwapTest(0x82438Ae8A7a17b276C98954873f1029dFDBfEa20);

    MainContract constant mainContract = MainContract(0x4A007ab655285a6C5C4002c192B0cF8987cA3e9F);

    function setUp() public {}

    function run() public {

        vm.broadcast();

        //IERC20(Currency.unwrap(currency1)).approve(address(0x82438Ae8A7a17b276C98954873f1029dFDBfEa20), type(uint256).max);

        //mainContract.placeMarketOrder{value:0.001 ether}(0, Currency.unwrap(currency0), Currency.unwrap(currency1), 0.001 ether);
    }
}