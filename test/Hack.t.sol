// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import {Test, console} from "forge-std/Test.sol";

import {ICurve} from "src/interfaces/ICurve.sol";
import {WETH9} from "src/interfaces/WETH9.sol";

contract HackTest is Test {
    WETH9 WETH = WETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    ICurve pool = ICurve(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);

    function setUp() public {
        vm.createSelectFork("mainnet", 17_806_055);
        vm.deal(address(this), 1_000_001 ether);
    }

    function testHack() public {
        console.log("balance before", address(this).balance);

        uint256[2] memory amount;
        amount[0] = 40_000 ether;
        amount[1] = 0;
        pool.add_liquidity{value: 40_000 ether}(amount, 0);

        console.log("balance after addliq", address(this).balance);
    }

}
