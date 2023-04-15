// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Test } from "forge-std/Test.sol";

abstract contract BaseTest is Test {
    bool internal debug;

    // Values are in the range [0; 3]
    // corresponding to the Yi Jing coins method values range [6; 9] adding +6

    function _isOld(uint8 value) internal pure returns (bool) {
        return value == 0 || value == 3; // true for 6 or 9
    }

    function _isYin(uint8 value) internal pure returns (bool) {
        return value % 2 == 0; // true for 6 or 8
    }

    function _getTrait(uint8[6] memory lines, uint8 n) internal pure returns (bool, bool) {
        return (_isOld(lines[n - 1]), _isYin(lines[n - 1]));
    }

    function _getOld(uint8 value) internal pure returns (uint8) {
        assert(value <= 1);
        return value == 0 ? 0 : 3;
    }

    function _getNew(uint8 value) internal pure returns (uint8) {
        assert(value <= 1);
        return value == 0 ? 2 : 1;
    }
}
