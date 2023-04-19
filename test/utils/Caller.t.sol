// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { Caller } from "src/utils/Caller.sol";

// Caller is Abstract Contract
contract Caller_ is Caller {
    constructor() Caller() {
        _caller = address(0x2);
    }

    // for modifier test
    function modifierTester() public onlyFromCaller {}
}

contract Caller_test is BaseTest {
    Caller_ caller;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.prank(DEPLOYER);
        caller = new Caller_();
    }

    function testSetUp() public {
        assertEq(caller.getCaller(), A_CONTRACT);
    }

    function testModifier() public {
        vm.expectRevert("Caller: not good one");
        caller.modifierTester();

        vm.prank(A_CONTRACT);
        caller.modifierTester();
    }
}
