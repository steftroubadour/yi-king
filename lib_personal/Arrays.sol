// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library Arrays {
    function toNumber(uint8[] memory x) public pure returns (uint256) {
        assert(x.length <= 32);

        uint256 number;

        for (uint8 n = 0; n < x.length; n++) {
            number += x[n] * 2 ** (8 * n);
        }

        return number;
    }

    function toUint8Array(uint256[] memory x) public pure returns (uint8[] memory) {
        uint8[] memory numbers = new uint8[](x.length);

        for (uint8 n = 0; n < x.length; n++) {
            assert(x[n] < 2 ** 8);
            numbers[n] = uint8(x[n]);
        }

        return numbers;
    }

    // Equals at each rank
    function areEquals(uint8[] memory x, uint8[] memory y) public pure returns (bool) {
        if (x.length != y.length) return false;
        if (x.length == 0) return true;

        for (uint8 n = 0; n < x.length; n++) {
            if (x[n] != y[n]) return false;
        }

        return true;
    }
}
