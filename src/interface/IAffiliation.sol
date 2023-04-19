// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { IAffiliationBase } from "src/interface/IAffiliationBase.sol";

interface IAffiliation is IAffiliationBase {
    function add(address, uint256) external;

    function addCommission(address, uint256) external;

    function ban(address) external;

    function getData(address) external view returns (AffiliateData memory);

    function getTotalBps() external view returns (uint256);

    function getTotalBalance() external view returns (uint256);

    function modify(address, AffiliateData memory) external;

    function remove(address) external;

    function toggleBlocked(address) external;

    function warn(address) external;

    function withdraw(address) external returns (uint256);
}
