// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

library Strings {
    function areStringsEquals(string memory str1, string memory str2) public pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked(str2));
    }

    function isEmptyString(string memory str1) public pure returns (bool) {
        return areStringsEquals(str1, "");
    }

    // first letter : begin is 1
    function slice(
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

    function remove0x(string memory text) public pure returns (string memory) {
        bytes memory textInBytes = bytes(text);
        uint256 textInBytesLength = textInBytes.length;
        bytes memory a = new bytes(textInBytesLength - 2);
        for (uint256 i = 2; i < textInBytes.length; i++) {
            a[i - 2] = textInBytes[i];
        }
        return string(a);
    }

    function removeUselessZeros(string memory text) public pure returns (string memory) {
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
