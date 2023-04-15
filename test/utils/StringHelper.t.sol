// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { console } from "forge-std/Test.sol";
import { BaseTest } from "./BaseTest.sol";
import { StringHelper } from "lib_personal/helper/StringHelper.sol";
import { FuzzRecorder } from "lib_personal/recorder/FuzzRecorder.sol";
import { VarRecorder } from "lib_personal/recorder/VarRecorder.sol";
import { TestHelper } from "lib_personal/helper/TestHelper.sol";

contract StringHelper_Test is BaseTest, TestHelper, VarRecorder, FuzzRecorder {
    uint256 public runs;

    function setUp() public {
        assertTrue(IS_TEST);

        // Uncomment to debug tests
        //_initDebug();
    }

    function _initDebug() internal {
        debug = true;

        // To use VarRecorder
        _initialiseStorages();
        runs = _readFoundryTomlValue("[fuzz]", "runs");
    }

    function test4_areStringsEquals() public {
        string memory str1 = "a string";
        string memory str2 = "a string";
        assertTrue(_areStringsEquals(str1, str2));

        str1 = "a string";
        str2 = "another string";
        assertFalse(_areStringsEquals(str1, str2));
    }

    function test4_isEmptyString() public {
        string memory str = "";
        assertTrue(_isEmptyString(str));

        str = "a string";
        assertFalse(_isEmptyString(str));
    }

    function test4_slice() public {
        string memory str = "a long string to test"; // 21 char
        assertEq(_slice(1, 3, str), "a l");
        assertEq(_slice(16, 21, str), "o test");
        assertEq(_slice(6, 17, str), "g string to ");
    }

    function test4_remove0x() public {
        string memory str = "0x123De4f78";
        assertEq(_remove0x(str), "123De4f78");
    }
}
