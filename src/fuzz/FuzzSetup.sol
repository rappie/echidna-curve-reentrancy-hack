// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzBase} from "fuzzlib/FuzzBase.sol";

import {ICurve} from "src/interfaces/ICurve.sol";
import {WETH9} from "src/interfaces/WETH9.sol";

contract FuzzSetup is FuzzBase {
    WETH9 WETH = WETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    ICurve pool = ICurve(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);

    constructor() FuzzBase() {
        vm.roll(17806055);
        vm.warp(1690722623);
    }
}
