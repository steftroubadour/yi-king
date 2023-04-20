// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits, console } from "test/utils/BaseTest.sol";
import { Affiliation } from "src/Affiliation.sol";
import { IAffiliationBase } from "src/interface/IAffiliationBase.sol";

contract Affiliation_ is Affiliation {
    function isExist(address affiliate) public view returns (bool) {
        return _isExist(affiliate);
    }

    function isBanned(address affiliate) public view returns (bool) {
        return _isBanned(affiliate);
    }

    function isBlocked(address affiliate) public view returns (bool) {
        return _isBanned(affiliate);
    }

    function requireValidBps(uint256 bps) public view {
        return _requireValidBps(bps);
    }
}

contract Affiliation_internals_test is BaseTest {
    Affiliation_ affiliation;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.startPrank(DEPLOYER);
        affiliation = new Affiliation_();
        affiliation.init(A_CONTRACT);
        vm.stopPrank();
        CALLER = A_CONTRACT;
        OWNER = DEPLOYER;
    }

    function testSetUp() public {
        assertEq(affiliation.getCaller(), CALLER);
        assertFalse(affiliation.paused());
    }

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    function testIsExist() public {
        assertFalse(affiliation.isExist(AN_USER));

        vm.prank(DEPLOYER);
        affiliation.add(AN_USER, 300);

        assertTrue(affiliation.isExist(AN_USER));
    }

    function testIsBanned() public {
        vm.expectRevert("Affiliation: not exists");
        affiliation.isBanned(AN_USER);

        vm.startPrank(DEPLOYER);
        affiliation.add(AN_USER, 300);
        assertFalse(affiliation.isBanned(AN_USER));

        affiliation.ban(AN_USER);
        assertTrue(affiliation.isBanned(AN_USER));
    }

    /*function testIsBlocked() public {
        vm.expectRevert("Affiliation: not exists");
        affiliation.isBlocked(AN_USER);

        vm.startPrank(DEPLOYER);
        affiliation.add(AN_USER, 300);
        assertFalse(affiliation.isBlocked(AN_USER));

        affiliation.getData(AN_USER);

        affiliation.toggleBlocked(AN_USER);

        affiliation.getData(AN_USER);
        vm.stopPrank();

        assertTrue(affiliation.isBlocked(AN_USER));
    }*/

    function testValidBps() public {
        affiliation.requireValidBps(200);

        vm.startPrank(DEPLOYER);
        affiliation.add(AN_USER, 9999);

        try affiliation.requireValidBps(2) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    /*////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    function testAddCommission() public {
        uint amount = 2 ether;
        vm.expectRevert("Caller: not good one");
        affiliation.addCommission(AN_USER, amount);

        vm.prank(DEPLOYER);
        affiliation.add(AN_USER, 300);

        vm.prank(A_CONTRACT);
        affiliation.addCommission(AN_USER, amount);

        Affiliation.AffiliateData memory data = affiliation.getData(AN_USER);
        assertEq(data.balance, (amount * data.bps) / 10000);

        vm.prank(DEPLOYER);
        affiliation.toggleBlocked(AN_USER);
        vm.prank(A_CONTRACT);
        vm.expectRevert("Affiliation: banned or blocked");
        affiliation.addCommission(AN_USER, amount);

        vm.prank(DEPLOYER);
        affiliation.toggleBlocked(AN_USER);
        vm.prank(A_CONTRACT);
        affiliation.addCommission(AN_USER, amount);

        vm.prank(DEPLOYER);
        affiliation.ban(AN_USER);
        vm.prank(A_CONTRACT);
        vm.expectRevert("Affiliation: banned or blocked");
        affiliation.addCommission(AN_USER, amount);

        // affiliate address is not registered
        uint256 affiliationTotalBalance = affiliation.getTotalBalance();
        vm.prank(A_CONTRACT);
        affiliation.addCommission(ANOTHER_USER, amount);
        assertEq(affiliation.getTotalBalance(), affiliationTotalBalance);
    }

    function testWithdraw() public {
        vm.expectRevert("Caller: not good one");
        affiliation.withdraw(AN_USER);

        vm.prank(DEPLOYER);
        affiliation.togglePause();
        vm.prank(CALLER);
        vm.expectRevert("Pausable: paused");
        affiliation.withdraw(AN_USER);

        vm.prank(DEPLOYER);
        affiliation.togglePause();

        vm.prank(CALLER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.withdraw(AN_USER);

        vm.prank(DEPLOYER);
        affiliation.add(AN_USER, 300);
        vm.prank(A_CONTRACT);
        affiliation.addCommission(AN_USER, 2 ether);

        uint256 affiliatesTotalBalance = affiliation.getTotalBalance();
        uint balance = affiliation.getData(AN_USER).balance;
        vm.prank(CALLER);
        uint amount = affiliation.withdraw(AN_USER);
        assertEq(amount, balance);
        assertEq(affiliatesTotalBalance - affiliation.getTotalBalance(), balance);
        assertEq(affiliation.getData(AN_USER).balance, 0);

        vm.prank(DEPLOYER);
        affiliation.toggleBlocked(AN_USER);
        vm.prank(CALLER);
        vm.expectRevert("Affiliation: banned or blocked");
        affiliation.withdraw(AN_USER);

        vm.prank(DEPLOYER);
        affiliation.toggleBlocked(AN_USER);
        vm.prank(CALLER);
        affiliation.withdraw(AN_USER);

        vm.prank(DEPLOYER);
        affiliation.ban(AN_USER);
        vm.prank(CALLER);
        vm.expectRevert("Affiliation: banned or blocked");
        affiliation.withdraw(AN_USER);
    }

    function testAdd() public {
        uint bps = 10000;
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.add(AN_USER, bps);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: bps limit");
        affiliation.add(AN_USER, bps);

        bps = 300;

        vm.prank(OWNER);
        affiliation.add(AN_USER, bps);

        Affiliation.AffiliateData memory data = affiliation.getData(AN_USER);
        assertEq(data.bps, bps);
        assertEq(data.balance, 0);
        assertFalse(data.blocked);
        assertFalse(data.banned);
        assertEq(data.warns, 0);
    }

    function testModify() public {
        Affiliation.AffiliateData memory data = IAffiliationBase.AffiliateData(
            10000,
            0,
            false,
            false,
            0
        );
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.modify(AN_USER, data);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.modify(AN_USER, data);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        uint balance = affiliation.getData(AN_USER).balance;

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: bps limit");
        affiliation.modify(AN_USER, data);

        // less
        data.bps = 200;
        vm.prank(OWNER);
        affiliation.modify(AN_USER, data);

        Affiliation.AffiliateData memory retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 200);
        assertEq(retrievedData.balance, balance); // Don't modify balance
        assertFalse(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 0);

        // more bps
        data.bps = 400;
        data.warns = 2;
        data.blocked = true;
        vm.prank(OWNER);
        affiliation.modify(AN_USER, data);

        retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 400);
        assertEq(retrievedData.balance, balance); // Don't modify balance
        assertTrue(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 2);
    }

    function testRemove() public {
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.remove(AN_USER);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.remove(AN_USER);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
        vm.prank(OWNER);
        affiliation.remove(AN_USER);

        assertFalse(affiliation.isExist(AN_USER));
        assertEq(affiliation.getTotalBps(), 0);
        assertEq(affiliation.getTotalBalance(), 0);
    }

    function testBan() public {
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.ban(AN_USER);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.ban(AN_USER);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
        vm.prank(OWNER);
        affiliation.ban(AN_USER);

        assertTrue(affiliation.isExist(AN_USER));
        Affiliation.AffiliateData memory retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 0);
        assertEq(retrievedData.balance, 0);
        assertFalse(retrievedData.blocked);
        assertTrue(retrievedData.banned);
        assertEq(retrievedData.warns, 0);
        assertEq(affiliation.getTotalBps(), 0);
        assertEq(affiliation.getTotalBalance(), 0);
    }

    function testWarn() public {
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.warn(AN_USER);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.warn(AN_USER);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
        vm.prank(OWNER);
        affiliation.warn(AN_USER);

        assertTrue(affiliation.isExist(AN_USER));
        Affiliation.AffiliateData memory retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 300);
        assertEq(retrievedData.balance, 0.09 ether);
        assertFalse(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 1);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
    }

    function testToggleBlocked() public {
        vm.expectRevert("Ownable: caller is not the owner");
        affiliation.toggleBlocked(AN_USER);

        vm.prank(OWNER);
        vm.expectRevert("Affiliation: not exists");
        affiliation.toggleBlocked(AN_USER);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
        vm.prank(OWNER);
        affiliation.toggleBlocked(AN_USER);

        assertTrue(affiliation.isExist(AN_USER));
        Affiliation.AffiliateData memory retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 300);
        assertEq(retrievedData.balance, 0.09 ether);
        assertTrue(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 0);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);

        vm.prank(OWNER);
        affiliation.toggleBlocked(AN_USER);

        assertTrue(affiliation.isExist(AN_USER));
        retrievedData = affiliation.getData(AN_USER);
        assertEq(retrievedData.bps, 300);
        assertEq(retrievedData.balance, 0.09 ether);
        assertFalse(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 0);
        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);
    }

    function testGetData() public {
        vm.expectRevert("Affiliation: not exists");
        affiliation.getData(AN_USER);

        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);
        vm.prank(OWNER);
        Affiliation.AffiliateData memory retrievedData = affiliation.getData(AN_USER);

        assertEq(retrievedData.bps, 300);
        assertEq(retrievedData.balance, 0.09 ether);
        assertFalse(retrievedData.blocked);
        assertFalse(retrievedData.banned);
        assertEq(retrievedData.warns, 0);
    }

    function testGetTotalBpsAndTotalBalance() public {
        vm.prank(OWNER);
        affiliation.add(AN_USER, 300);
        vm.prank(CALLER);
        affiliation.addCommission(AN_USER, 3 ether);

        assertEq(affiliation.getTotalBps(), 300);
        assertEq(affiliation.getTotalBalance(), 0.09 ether);

        vm.prank(OWNER);
        affiliation.remove(AN_USER);
        assertEq(affiliation.getTotalBps(), 0);
        assertEq(affiliation.getTotalBalance(), 0);
    }
}
