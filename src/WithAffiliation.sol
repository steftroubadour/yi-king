// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IAffiliationBase } from "src/interface/IAffiliationBase.sol";
import { IAffiliation } from "src/interface/IAffiliation.sol";

abstract contract WithAffiliation is IAffiliationBase {
    address private _affiliation;

    constructor(address affiliation) {
        _affiliation = affiliation;
    }

    function getAffiliation() public view returns (address) {
        return address(_affiliation);
    }

    function _addAffiliateCommission(address affiliate, uint256 amount) internal {
        IAffiliation(_affiliation).addCommission(affiliate, amount);
    }

    function _setAffiliation(address affiliation) internal {
        _affiliation = affiliation;
    }
}
