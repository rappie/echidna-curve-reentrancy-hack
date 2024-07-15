// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import {Test, console} from "forge-std/Test.sol";

import {ICurve} from "src/interfaces/ICurve.sol";
import {WETH9} from "src/interfaces/WETH9.sol";

contract HackTest is Test {
    function setUp() public {}

    function testHack() public {
        console.log("testHack");
    }

}
