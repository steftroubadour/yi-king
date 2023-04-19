// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Pausable } from "src/utils/Pausable.sol";

abstract contract Caller is Pausable {
    address _caller;

    modifier onlyFromCaller() {
        require(msg.sender == _caller, "Caller: not good one");
        _;
    }

    function getCaller() public view returns (address) {
        return _caller;
    }
}
