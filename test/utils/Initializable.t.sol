// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { Initializable } from "src/utils/Initializable.sol";

// Initializable is Abstract Contract
contract Initializable_ is Initializable {
    function initialized() public view returns (bool) {
        return _initialized;
    }

    // for modifier test
    function modifierTester() public whenNotPaused {}
}

contract Initializable_test is BaseTest {
    Initializable_ t;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.prank(DEPLOYER);
        t = new Initializable_();
        OWNER = DEPLOYER;
    }

    function testSetUp() public {
        assertFalse(t.initialized());
        assertEq(t.getCaller(), address(0));
        assertTrue(t.paused());
        assertEq(t.owner(), DEPLOYER);
    }

    function testInit() public {
        vm.prank(AN_USER);
        vm.expectRevert("Ownable: caller is not the owner");
        t.init(A_CONTRACT);

        vm.prank(OWNER);
        t.init(A_CONTRACT);
        assertTrue(t.initialized());
        assertEq(t.getCaller(), A_CONTRACT);
        assertFalse(t.paused());

        vm.prank(OWNER);
        t.togglePause();
        vm.prank(OWNER);
        vm.expectRevert("Initializable: already done");
        t.init(A_CONTRACT);
    }
}
