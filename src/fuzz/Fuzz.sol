// SPDX-License-Identifier: MIT
import {FuzzSetup} from "./FuzzSetup.sol";

contract Fuzz is FuzzSetup {
    constructor() payable FuzzSetup() {}

    function testSomething() public {
        t(false, "testSomething");
    }
}
