// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Caller } from "src/utils/Caller.sol";

abstract contract Initializable is Caller {
    bool _initialized;

    function init(address caller) external onlyOwner whenPaused {
        require(!_initialized, "Initializable: already done");
        _initialized = true;
        _caller = caller;
        _togglePause();
    }
}
