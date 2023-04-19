// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { WithAffiliation } from "src/WithAffiliation.sol";
import { Affiliation } from "src/Affiliation.sol";
import { IAffiliationBase } from "src/interface/IAffiliationBase.sol";

contract WithAffiliation_ is WithAffiliation {
    constructor(address affiliation) WithAffiliation(affiliation) {}

    function addAffiliateCommission(address affiliate, uint256 amount) public {
        return _addAffiliateCommission(affiliate, amount);
    }
}

contract WithAffiliation_test is BaseTest {
    Affiliation affiliation;
    WithAffiliation_ withAffiliation;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.startPrank(DEPLOYER);
        affiliation = new Affiliation();
        withAffiliation = new WithAffiliation_(address(affiliation));
        affiliation.init(address(withAffiliation));
        affiliation.add(AN_USER, 100);
        vm.stopPrank();
    }

    function testSetUp() public {
        assertEq(withAffiliation.getAffiliation(), address(affiliation));
        assertEq(affiliation.getCaller(), address(withAffiliation));
    }

    function testAddAffiliateCommission() public {
        uint256 amount = 3 ether;
        IAffiliationBase.AffiliateData memory oldData = affiliation.getData(AN_USER);
        withAffiliation.addAffiliateCommission(AN_USER, amount);
        IAffiliationBase.AffiliateData memory newData = affiliation.getData(AN_USER);
        assertTrue(oldData.balance != newData.balance);
        assertEq(newData.balance, oldData.balance + (amount * oldData.bps) / 10000);
    }
}
