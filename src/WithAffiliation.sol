// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IAffiliationBase } from "src/interface/IAffiliationBase.sol";
import { IAffiliation } from "src/interface/IAffiliation.sol";

abstract contract WithAffiliation is IAffiliationBase {
    IAffiliation private _affiliation;

    constructor(address affiliation) {
        _affiliation = IAffiliation(affiliation);
    }

    function _addAffiliateCommission(address affiliate, uint256 amount) internal {
        _affiliation.addCommission(affiliate, amount);
    }

    function getAffiliation() public view returns (address) {
        return address(_affiliation);
    }
}
