// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "src/YiJingImagesGenerator.sol";

contract Metadata_TEST is Test {
    YiJingImagesGenerator image;

    function setUp() public {
        image = new YiJingImagesGenerator();
    }

    function _getLastNBits(uint256 x, uint256 n) internal pure returns (uint256) {
        // Example, last 3 bits
        // x        = 1101 = 13
        // mask     = 0111 = 7
        // x & mask = 0101 = 5
        uint256 mask = (1 << n) - 1;
        return x & mask;
    }

    function _getRangeOfBits(uint256 x, uint256 from, uint256 to) internal pure returns (uint256) {
        if (from == 0) return _getLastNBits(x, to);

        return _getLastNBits(x, to) - _getLastNBits(x, from - 1);
    }

    function _sliceBits(uint256 x, uint256 from, uint256 to) internal pure returns (uint256) {
        return _getRangeOfBits(x, from, to) >> (from - 1);
    }

    function _isOld(uint8 value) internal pure returns (bool) {
        return value >= 2;
    }

    function _isYin(uint8 value) internal pure returns (bool) {
        return value % 2 == 0;
    }

    function getTrait(
        uint8[6] memory lines,
        uint8 n
    ) internal pure returns (bool isOld_, bool isYin_) {
        return (lines[n - 1] >= 2, lines[n - 1] % 2 == 0);
    }

    function testHexagrams() public {
        uint8[6] memory result = [3, 1, 2, 3, 0, 1];
        bool isOld;
        bool isYin;

        //uint8[6] memory from6Bits = image.getFrom6Bits(result);
        //uint8[6] memory to6Bits = image.getTo6Bits(result);

        emit log_string("result");
        for (uint8 i = 1; i <= 6; i++) {
            (isOld, isYin) = getTrait(result, i);
            emit log_named_string(
                string.concat("line ", vm.toString(i)),
                isYin ? (isOld ? "old yin" : "new yin") : (isOld ? "old yang" : "new yang")
            );
        }
        emit log_named_string("result svg", image.getNftImage(result));
    }
}
