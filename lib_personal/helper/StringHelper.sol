// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

// /!\ does not work as library
abstract contract StringHelper {
    function _areStringsEquals(
        string memory str1,
        string memory str2
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function _isEmptyString(string memory str1) internal pure returns (bool) {
        return _areStringsEquals(str1, "");
    }

    // first letter : begin is 1
    function _slice(
        uint256 begin,
        uint256 end,
        string memory text
    ) internal pure returns (string memory) {
        bytes memory a = new bytes(end - begin + 1);
        for (uint256 i = 0; i <= end - begin; i++) {
            a[i] = bytes(text)[i + begin - 1];
        }
        return string(a);
    }

    function _remove0x(string memory text) internal pure returns (string memory) {
        bytes memory textInBytes = bytes(text);
        uint256 textInBytesLength = textInBytes.length;
        bytes memory a = new bytes(textInBytesLength - 2);
        for (uint256 i = 2; i < textInBytes.length; i++) {
            a[i - 2] = textInBytes[i];
        }
        return string(a);
    }

    function _removeUselessZeros(string memory text) internal pure returns (string memory) {
        bool canZeroBeRemoved = true;
        bytes memory textInBytes = bytes(text);
        uint256 textInBytesLength = textInBytes.length;
        bytes memory a = new bytes(textInBytesLength - 2);
        for (uint256 i = 2; i < textInBytes.length; i++) {
            if (canZeroBeRemoved && textInBytes[i] == 0x30) continue;
            a[i - 2] = textInBytes[i];
            canZeroBeRemoved = false;
        }
        return string.concat("0x", string(a));
    }
}
