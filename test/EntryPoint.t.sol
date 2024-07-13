// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {TickMath} from "v4-core/src/libraries/TickMath.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {CurrencyLibrary, Currency} from "v4-core/src/types/Currency.sol";
import {PoolSwapTest} from "v4-core/src/test/PoolSwapTest.sol";
import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {StateLibrary} from "v4-core/src/libraries/StateLibrary.sol";
import {OrderPlacerMock} from "../src/mocks/OrderPlacerMock.sol";
import {MainContract} from "../src/MainContract.sol";
import {IOrderMatcher} from "../src/IOrderMatcher.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";

contract CounterTest is Test, Deployers {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;
    using StateLibrary for IPoolManager;

    EntryPoint hook;
    PoolId poolId;
    MainContract mainContract;

    function setUp() public {
        // creates the pool manager, utility routers, and test tokens
        Deployers.deployFreshManagerAndRouters();
        Deployers.deployMintAndApprove2Currencies();

        // Deploy the hook to an address with the correct flags
        address flags = address(
            uint160(
                Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_SWAP_RETURNS_DELTA_FLAG
            ) ^ (0x4444 << 144) // Namespace the hook to avoid collisions
        );

        OrderPlacerMock orderPlacerMock = new OrderPlacerMock();
        deployCodeTo("EntryPoint.sol:EntryPoint", abi.encode(manager, orderPlacerMock), flags);
        hook = EntryPoint(flags);
        orderPlacerMock.setHook(hook);

        // Create the pool
        key = PoolKey(currency0, currency1, 3000, 60, IHooks(hook));
        poolId = key.toId();
        manager.initialize(key, SQRT_PRICE_1_1, ZERO_BYTES);

        // Provide full-range liquidity to the pool
        modifyLiquidityRouter.modifyLiquidity(
            key,
            IPoolManager.ModifyLiquidityParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10_000 ether, 0),
            ZERO_BYTES
        );

        mainContract = new MainContract(swapRouter, address(hook));
    }

    function testEntryPointHooks() public {
        bool zeroForOne = true;
        uint256 amount = 1e18; // negative number indicates exact input swap!
        mainContract.placeMarketOrder(0, Currency.unwrap(currency0), Currency.unwrap(currency1), amount);
        mainContract.placeMarketOrder(1, Currency.unwrap(currency0), Currency.unwrap(currency1), amount);
    }
}
