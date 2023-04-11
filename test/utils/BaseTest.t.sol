// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest } from "test/utils/BaseTest.sol";

contract BaseTest_test is BaseTest {
    function setUp() public {
        assertTrue(IS_TEST);
    }

    function test__getTrait() public {
        uint8[6] memory result = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        bool[6] memory expectedIsOld = [true, false, false, true, true, false];
        bool[6] memory expectedIsYin = [false, false, true, false, true, false];
        bool isOld;
        bool isYin;

        for (uint8 i = 1; i <= 6; i++) {
            (isOld, isYin) = _getTrait(result, i);
            assertEq(isOld, expectedIsOld[i - 1]);
            assertEq(isYin, expectedIsYin[i - 1]);
        }
    }

    function test__getOld() public {
        uint8 value = 0; // yin
        assertEq(_getOld(value), 0);

        value = 1; // yang
        assertEq(_getOld(value), 3);
    }

    function test__getNew() public {
        uint8 value = 0; // yin
        assertEq(_getNew(value), 2);

        value = 1; // yang
        assertEq(_getNew(value), 1);
    }
}
