// SPDX-License-Identifier: MIT
import {FuzzSetup} from "./FuzzSetup.sol";

contract Fuzz is FuzzSetup {
    constructor() payable FuzzSetup() {}

    function testSomething() public {
		uint256 balance = address(this).balance;
        log("initial balance", balance);


		t(false, "done");
    }
}
