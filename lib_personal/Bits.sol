// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library Bits {
    function getLastNBits(uint256 x, uint256 n) public pure returns (uint256) {
        // Example, last 3 bits
        // x        = 1101 = 13
        // mask     = 0111 = 7
        // x & mask = 0101 = 5
        uint256 mask = (1 << n) - 1;
        return x & mask;
    }

    function getRangeOfBits(uint256 x, uint256 from, uint256 to) public pure returns (uint256) {
        if (from == 0) return getLastNBits(x, to);

        return getLastNBits(x, to) - getLastNBits(x, from - 1);
    }

    function sliceBits(uint256 x, uint256 from, uint256 to) public pure returns (uint256) {
        return getRangeOfBits(x, from, to) >> (from - 1);
    }
}
