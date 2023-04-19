// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract Pausable is Ownable {
    bool private _paused;

    /// @dev Initializes the contract in paused state.
    constructor() {
        _paused = true;
    }

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /// @dev Toggle paused state.
    function togglePause() external onlyOwner {
        _togglePause();
    }

    function _togglePause() internal {
        _paused = !_paused;
    }

    function paused() external view returns (bool) {
        return _paused;
    }
}
