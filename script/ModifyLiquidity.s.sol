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

contract DeployPoolScript is Script {
    bytes constant ZERO_BYTES = Constants.ZERO_BYTES;

    uint160 constant SQRT_PRICE_1_1 = Constants.SQRT_PRICE_1_1;

    IHooks constant hook = IHooks(0x0DC1B581e91C13Fcb9e0d7135A47cC2a64f20088);

    Currency constant currency0 = Currency.wrap(0x0000000000000000000000000000000000000000);

    Currency constant currency1 = Currency.wrap(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    PoolModifyLiquidityTest constant modifyLiquidityRouter = PoolModifyLiquidityTest(0x2b925D1036E2E17F79CF9bB44ef91B95a3f9a084);

    function setUp() public {}

    function run() public {


        PoolKey memory key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));

        vm.broadcast();

        modifyLiquidityRouter.modifyLiquidity{value:0.01 ether}(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 0.01 ether, 0),
            ZERO_BYTES
        );
    }
}