// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest } from "test/utils/BaseTest.sol";
import { YiJingImagesGenerator } from "src/YiJingImagesGenerator.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Bits } from "lib_personal/Bits.sol";
import { Strings as Strings2 } from "lib_personal/Strings.sol";

// To test internal functions
contract YiJingImagesGenerator_ is YiJingImagesGenerator {
    function getFrom6Bits(uint8[6] memory lines) public pure returns (uint8[6] memory) {
        return _getFrom6Bits(lines);
    }

    function getTo6Bits(uint8[6] memory lines) public pure returns (uint8[6] memory) {
        return _getTo6Bits(lines);
    }
}

contract YiJingImagesGenerator_internals_test is BaseTest {
    YiJingImagesGenerator_ imagesGenerator;

    function setUp() public {
        imagesGenerator = new YiJingImagesGenerator_();
    }

    function test4_getFrom6Bits() public {
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        uint8[6] memory expectedResult = [1, 1, 0, 1, 0, 1];
        lines = imagesGenerator.getFrom6Bits(lines);
        for (uint8 i = 0; i < 6; i++) {
            assertTrue(lines[i] <= 1);
            assertEq(lines[i], expectedResult[i]);
        }
    }

    function test4_getTo6Bits() public {
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        uint8[6] memory expectedResult = [0, 1, 0, 0, 1, 1];
        lines = imagesGenerator.getTo6Bits(lines);
        for (uint8 i = 0; i < 6; i++) {
            assertTrue(lines[i] <= 1);
            assertEq(lines[i], expectedResult[i]);
        }
    }

    function test4_getFromAndTo6Bits(uint8[6] memory numbers, bool[6] memory isOld) public {
        // Construct drawn hexagram and expected From & To results
        uint8[6] memory lines;
        uint8[6] memory from;
        uint8[6] memory to;
        for (uint8 n = 0; n < 6; n++) {
            from[n] = uint8(bound(numbers[n], 0, 1));
            lines[n] = uint8(isOld[n] ? _getOld(from[n]) : _getNew(from[n]));
            to[n] = uint8(isOld[n] ? (from[n] + 1) % 2 : from[n]);
        }

        numbers = imagesGenerator.getFrom6Bits(lines);
        for (uint8 i = 0; i < 6; i++) {
            assertTrue(numbers[i] <= 1);
            assertEq(numbers[i], from[i]);
        }

        numbers = imagesGenerator.getTo6Bits(lines);
        for (uint8 i = 0; i < 6; i++) {
            assertTrue(numbers[i] <= 1);
            assertEq(numbers[i], to[i]);
        }
    }
}

contract YiJingImagesGenerator_test is BaseTest {
    YiJingImagesGenerator imagesGenerator;

    function setUp() public {
        imagesGenerator = new YiJingImagesGenerator();

        assertTrue(IS_TEST);
    }

    function test4getNftImage() public {
        uint8[6] memory result = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        //emit log_named_string("result svg", image.getNftImage(result));
        string memory nftImage = imagesGenerator.getNftImage(result);
        assertFalse(Strings2.isEmptyString(nftImage));
        assertEq(Strings2.slice(1, 26, nftImage), "data:image/svg+xml;base64,");
    }

    function test4getNftImage(uint8[6] memory numbers) public {
        for (uint8 n = 0; n < 6; n++) {
            numbers[n] = uint8(bound(numbers[n], 0, 3));
        }

        //emit log_named_string("result svg", image.getNftImage(result));
        string memory nftImage = imagesGenerator.getNftImage(numbers);
        assertFalse(Strings2.isEmptyString(nftImage));
        assertEq(Strings2.slice(1, 26, nftImage), "data:image/svg+xml;base64,");
    }

    function test4getHexagramImageForVariation() public {
        uint8[6] memory result = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        string memory image;
        uint hexagramNo;
        for (uint8 variation = 0; variation < 3; variation++) {
            (hexagramNo, image) = imagesGenerator.getHexagramImageForVariation(result, variation);
            assertFalse(Strings2.isEmptyString(image));
            assertEq(Strings2.slice(1, 26, image), "data:image/svg+xml;base64,");

            if (variation == 0) assertEq(hexagramNo, 0);
            else if (variation == 1) assertEq(hexagramNo, 38);
            else {
                assertEq(variation, 2);
                assertEq(hexagramNo, 59);
            }
        }
    }

    function test4getHexagramImageForVariation(uint8[6] memory numbers, uint8 variation) public {
        for (uint8 n = 0; n < 6; n++) {
            numbers[n] = uint8(bound(numbers[n], 0, 3));
        }
        variation = uint8(bound(variation, 0, 2));
        string memory image;
        uint hexagramNo;
        (hexagramNo, image) = imagesGenerator.getHexagramImageForVariation(numbers, variation);
        assertFalse(Strings2.isEmptyString(image));
        assertEq(Strings2.slice(1, 26, image), "data:image/svg+xml;base64,");
    }
}
