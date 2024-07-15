// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

interface ICurve {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external payable returns (uint256);

    function add_liquidity(
        uint256[2] memory amounts,
        uint256 min_mint_amount
    ) external payable returns (uint256);

    function remove_liquidity(
        uint256 token_amount,
        uint256[2] memory min_amounts
    ) external;
}
