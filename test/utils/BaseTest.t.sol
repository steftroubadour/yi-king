// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { Test } from "forge-std/Test.sol";

contract BaseTest_ is BaseTest {
    function isOld(uint8 value) public pure returns (bool) {
        return _isOld(value);
    }

    function isYin(uint8 value) public pure returns (bool) {
        return _isYin(value);
    }

    function getTrait(uint8[6] memory lines, uint8 n) public pure returns (bool, bool) {
        return _getTrait(lines, n);
    }

    function getOld(uint8 value) public pure returns (uint8) {
        return _getOld(value);
    }

    function getNew(uint8 value) public pure returns (uint8) {
        return _getNew(value);
    }
}

contract BaseTest_test is Test {
    BaseTest_ t;

    function setUp() public {
        assertTrue(IS_TEST);

        t = new BaseTest_();
    }

    function test__getTrait() public {
        uint8[6] memory result = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        bool[6] memory expectedIsOld = [true, false, false, true, true, false];
        bool[6] memory expectedIsYin = [false, false, true, false, true, false];
        bool isOld;
        bool isYin;

        for (uint8 i = 1; i <= 6; i++) {
            (isOld, isYin) = t.getTrait(result, i);
            assertEq(isOld, expectedIsOld[i - 1]);
            assertEq(isYin, expectedIsYin[i - 1]);
        }
    }

    function test__getOld() public {
        uint8 value = 0; // yin
        assertEq(t.getOld(value), 0);

        value = 1; // yang
        assertEq(t.getOld(value), 3);
    }

    function test__getNew() public {
        uint8 value = 0; // yin
        assertEq(t.getNew(value), 2);

        value = 1; // yang
        assertEq(t.getNew(value), 1);
    }

    function testIsStringContain() public {
        string memory where = "0;//yin+123";
        string memory what = "//yin";
        assertTrue(t.isStringContain(what, where));

        what = "yang";
        assertFalse(t.isStringContain(what, where));
    }
}
