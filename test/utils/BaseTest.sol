// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Test, console } from "forge-std/Test.sol";
import { Arrays, Bits } from "foundry-test-helpers/library/Libraries.sol";
import { FuzzRecorder } from "foundry-test-helpers/recorder/FuzzRecorder.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
abstract contract BaseTest is Test, FuzzRecorder {
    address AN_USER = address(0x1);
    address A_CONTRACT = address(0x2);
    address DEPLOYER = address(0x3);
    address ANOTHER_CONTRACT = address(0x4);
    address AN_AFFILIATE = address(0x5);
    address ANOTHER_USER = address(0x6);
    address OWNER;
    address CALLER;

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

    function isStringContain(string memory what, string memory where) public pure returns (bool) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return true;
        }

        return false;
    }

    function getPositionStringContained(
        string memory what,
        string memory where
    ) public pure returns (uint256) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return i + 1;
        }

        return 0;
    }

    function findFirstCharPositionAfter(
        string memory char,
        uint256 startPosition,
        string memory where
    ) public pure returns (uint256) {
        require(bytes(char).length == 1 && startPosition != 0);
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = startPosition - 1; i < whereBytesLength - 1; i++) {
            if (areStringsEquals(slice(i + 1, i + 1, where), char)) return i + 1;
        }

        return 0;
    }

    /*/////////////////////////////////////////////
                        DEPLOYERS
    /////////////////////////////////////////////*/
}
