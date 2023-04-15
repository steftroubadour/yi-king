// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { TestBase } from "forge-std/Test.sol";
import { StringHelper } from "./StringHelper.sol";

abstract contract TestHelper is TestBase, StringHelper {
    function _bound2(uint256 x, uint256 min, uint256 max) internal pure virtual returns (uint256) {
        if (x >= min && x <= max) return x;

        uint256 size = max - min + 1;
        uint256 diff;
        uint256 rem;

        if (x > max) {
            diff = x - max;
            rem = diff % size;
            return min + rem;
        }
        // x < min
        diff = min - x;
        rem = diff % size;
        return min + rem;
    }

    function bound2(uint256 x, uint256 min, uint256 max) internal pure virtual returns (uint256) {
        uint256 n = _bound2(x, min, max);

        if (n >= min && n <= min + 3) {
            n = _bound2(Math.sqrt(x), min, max);
        }

        return n;
    }

    function _mustExecuteTest(uint256 randomNumber, uint256 max) internal pure returns (bool) {
        // assuming iterations count is set to 256
        uint256 number = bound2(randomNumber, 1, 256);

        // assuming 95% of values will be tested if range is multiplied by 2
        return number <= 2 * max;
    }

    function _getRevertMsg(bytes memory _data) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (without a revert message)
        if (_data.length < 68) return "Transaction reverted silently";

        assembly {
            // Slice the sighash.
            _data := add(_data, 0x04)
        }
        return abi.decode(_data, (string)); // All that remains is the revert string
    }

    function _readFoundryTomlValue(
        string memory profileName,
        string memory varName
    ) internal returns (uint256) {
        bool isGoodProfile = false;
        string memory line = "";
        vm.closeFile("./foundry.toml");
        uint256 lineNumber = 0;
        uint256 maxLineLength = 400;

        while (!isGoodProfile && lineNumber <= maxLineLength) {
            line = vm.readLine("./foundry.toml");
            if (
                bytes(line).length > 0 &&
                !_areStringsEquals(_slice(1, 1, line), "#") &&
                _areStringsEquals(line, profileName)
            ) isGoodProfile = true;

            lineNumber++;
        }

        bool isGoodLine = false;

        while (!isGoodLine && lineNumber <= maxLineLength) {
            line = vm.readLine("./foundry.toml");
            if (
                bytes(line).length > 0 &&
                !_areStringsEquals(_slice(1, 1, line), "#") &&
                !_areStringsEquals(_slice(1, 1, line), "[") &&
                _areStringsEquals(_slice(1, bytes(varName).length, line), varName)
            ) isGoodLine = true;

            lineNumber++;
        }

        return vm.parseUint(_slice(bytes(varName).length + 4, bytes(line).length, line));
    }
}
