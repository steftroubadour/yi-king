// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IAffiliationBase {
    struct AffiliateData {
        uint256 bps; // slot 0
        uint256 balance; // slot 1
        bool banned; // definitive // slot 2
        bool blocked; // pause affiliate actions
        uint8 warns; // warnings count
    }
}
