// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Initializable } from "src/utils/Initializable.sol";
import { IAffiliation } from "src/interface/IAffiliation.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title Affiliation contract
// Affiliation storage not needs lot of Storage.
// If contract is upgraded, it is possible to copy storage to new contract with no excessive cost.
contract Affiliation is IAffiliation, Initializable {
    /*////////////////////////////////////////////////////
                      REVERT REASONS
    ////////////////////////////////////////////////////*/
    string constant REVERT_NOT_EXISTS = "Affiliation: not exists";
    string constant REVERT_EXISTS = "Affiliation: already exists";
    string constant REVERT_CANT = "Affiliation: banned or blocked";
    string constant REVERT_BPS = "Affiliation: bps limit";
    string constant REVERT_NOT_ALLOWED = "Affiliation: not allowed";

    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private _affiliatesAddresses;

    uint256 private _totalBps;
    uint256 private _totalBalance;

    mapping(address => AffiliateData) private _affiliates;

    /*////////////////////////////////////////////////////
                      MODIFIERS
    ////////////////////////////////////////////////////*/
    modifier exists(address affiliate) {
        require(_isExist(affiliate), REVERT_NOT_EXISTS);
        _;
    }

    modifier notExists(address affiliate) {
        require(!_isExist(affiliate), REVERT_EXISTS);
        _;
    }

    modifier canDo(address affiliate) {
        require(!_isBanned(affiliate) && !_isBlocked(affiliate), REVERT_CANT);
        _;
    }

    /*////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    // To not block tx, revert must handle by Caller contract
    function addCommission(address affiliate, uint256 amount) external onlyFromCaller {
        if (!_isExist(affiliate)) return;
        require(!_isBanned(affiliate) && !_isBlocked(affiliate), REVERT_CANT);
        _affiliates[affiliate].balance += (_affiliates[affiliate].bps * amount) / 10000;
        _totalBalance += _affiliates[affiliate].balance;
    }

    function withdraw(
        address affiliate
    )
        external
        onlyFromCaller
        whenNotPaused
        exists(affiliate)
        canDo(affiliate)
        returns (uint256 amount)
    {
        uint256 balance = _affiliates[affiliate].balance;
        _affiliates[affiliate].balance = 0;
        _totalBalance -= balance;
        return balance;
    }

    function add(address affiliate, uint256 bps) external onlyOwner notExists(affiliate) {
        _requireValidBps(bps);
        _affiliates[affiliate].bps = bps;
        _affiliatesAddresses.add(affiliate);
        _totalBps += bps;
    }

    // can't modify affiliate balance
    function modify(
        address affiliate,
        AffiliateData memory data
    ) external onlyOwner exists(affiliate) {
        uint256 oldBps = _affiliates[affiliate].bps;
        if (data.bps > oldBps) _requireValidBps(data.bps - oldBps);
        _affiliates[affiliate].bps = data.bps;
        _affiliates[affiliate].banned = data.banned;
        _affiliates[affiliate].blocked = data.blocked;
        _affiliates[affiliate].warns = data.warns;
        if (data.bps >= oldBps) _totalBps += data.bps - oldBps;
        else _totalBps -= oldBps - data.bps;
    }

    function remove(address affiliate) external onlyOwner exists(affiliate) {
        uint256 bps = _affiliates[affiliate].bps;
        uint256 balance = _affiliates[affiliate].balance;
        _affiliates[affiliate] = AffiliateData(0, 0, false, false, 0);
        _affiliatesAddresses.remove(affiliate);
        _totalBps -= bps;
        _totalBalance -= balance;
    }

    function ban(address affiliate) external onlyOwner exists(affiliate) {
        _affiliates[affiliate].banned = true;
        uint256 bps = _affiliates[affiliate].bps;
        uint256 balance = _affiliates[affiliate].balance;
        _affiliates[affiliate].balance = 0;
        _affiliates[affiliate].bps = 0;
        _totalBps -= bps;
        _totalBalance -= balance;
    }

    function warn(address affiliate) external onlyOwner exists(affiliate) {
        _affiliates[affiliate].warns++;
    }

    function toggleBlocked(address affiliate) external onlyOwner exists(affiliate) {
        _affiliates[affiliate].blocked = !_affiliates[affiliate].blocked;
    }

    function getData(
        address affiliate
    ) external view exists(affiliate) returns (AffiliateData memory) {
        return _affiliates[affiliate];
    }

    function getTotalBps() external view returns (uint256) {
        return _totalBps;
    }

    function getTotalBalance() external view returns (uint256) {
        return _totalBalance;
    }

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    function _isExist(address affiliate) internal view returns (bool) {
        return _affiliatesAddresses.contains(affiliate);
    }

    function _isBanned(address affiliate) internal view exists(affiliate) returns (bool) {
        return _affiliates[affiliate].banned;
    }

    function _isBlocked(address affiliate) internal view exists(affiliate) returns (bool) {
        return _affiliates[affiliate].blocked;
    }

    function _requireValidBps(uint256 bps) internal view {
        require(_totalBps + bps < 10000, REVERT_BPS);
    }
}
