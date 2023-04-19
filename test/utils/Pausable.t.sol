// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { Pausable } from "src/utils/Pausable.sol";

// Pausable is Abstract Contract
contract Pausable_ is Pausable {
    // for modifier test
    function modifierTester() public whenNotPaused {}
}

contract Pausable_test is BaseTest {
    Pausable_ pausable;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.prank(DEPLOYER);
        pausable = new Pausable_();
        OWNER = DEPLOYER;
    }

    function testSetUp() public {
        assertTrue(pausable.paused());
        assertEq(pausable.owner(), DEPLOYER);
    }

    function testTogglePause() public {
        vm.expectRevert("Ownable: caller is not the owner");
        pausable.togglePause();

        vm.prank(OWNER);
        pausable.togglePause();
        assertFalse(pausable.paused());

        vm.prank(OWNER);
        pausable.togglePause();
        assertTrue(pausable.paused());
    }

    function testModifier() public {
        vm.expectRevert("Pausable: paused");
        pausable.modifierTester();

        vm.prank(OWNER);
        pausable.togglePause();
        pausable.modifierTester();
    }
}
