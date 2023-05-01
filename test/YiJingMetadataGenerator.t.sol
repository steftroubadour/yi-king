// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits } from "test/utils/BaseTest.sol";
import { Base64Std } from "test/utils/Base64Std.sol";
import { YiJingMetadataGenerator, IYiJingBase } from "src/YiJingMetadataGenerator.sol";
import { YiJingImagesGenerator } from "src/YiJingImagesGenerator.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

// Internal functions
contract YiJingMetadataGenerator_ is YiJingMetadataGenerator {
    constructor(address imagesGenerator) YiJingMetadataGenerator(imagesGenerator) {}

    function getMetadataAttributes(
        NftDataExtended memory nftData
    ) public pure returns (string memory) {
        return _getMetadataAttributes(nftData);
    }
}

contract YiJingMetadataGenerator_internals_test is BaseTest {
    YiJingMetadataGenerator_ metadataGenerator;

    function setUp() public {
        metadataGenerator = new YiJingMetadataGenerator_(A_CONTRACT);
    }

    function test_getMetadataAttributes() public {
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        IYiJingBase.NftDataExtended memory nftData = IYiJingBase.NftDataExtended(
            1,
            IYiJingBase.Hexagram(lines),
            1234567890,
            false,
            "",
            ""
        );

        string memory attributes = metadataGenerator.getMetadataAttributes(nftData);
        assertFalse(isEmptyString(attributes));
        assertEq(slice(1, 1, attributes), "[");
    }
}

contract YiJingMetadataGenerator_test is BaseTest {
    YiJingMetadataGenerator metadataGenerator;
    YiJingImagesGenerator imagesGenerator;
    YiJingImagesGenerator imagesGenerator2;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.startPrank(DEPLOYER);
        imagesGenerator = new YiJingImagesGenerator();
        metadataGenerator = new YiJingMetadataGenerator(address(imagesGenerator));
        imagesGenerator.init(address(metadataGenerator));
        vm.stopPrank();

        OWNER = DEPLOYER;
    }

    function testSetup() public {
        assertEq(metadataGenerator.getLastVersion(), 0);
    }

    function testSetNewImagesGenerator() public {
        vm.prank(OWNER);
        metadataGenerator.setNewImagesGenerator(A_CONTRACT);
        assertEq(metadataGenerator.getLastVersion(), 1);
    }

    function testGetJsonMetadata() public {
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        IYiJingBase.NftDataExtended memory nftData = IYiJingBase.NftDataExtended(
            1,
            IYiJingBase.Hexagram(lines),
            1234567890,
            true,
            "123ABC",
            "encryption method"
        );

        string memory metadata = metadataGenerator.getJsonMetadata(nftData);
        assertFalse(isEmptyString(metadata));
        assertEq(slice(1, 29, metadata), "data:application/json;base64,");

        string memory decodedMetadata = string(
            Base64Std.decode(slice(30, bytes(metadata).length, metadata))
        );
        uint startPosition = getPositionStringContained(
            "data:image/svg+xml;base64,",
            decodedMetadata
        ) + 26;
        string memory encodedImage = slice(
            startPosition,
            findFirstCharPositionAfter('"', startPosition, decodedMetadata) - 1,
            decodedMetadata
        );
        assertTrue(isStringContain('"name":"Yi Jing Hexagram #1"', decodedMetadata));
        assertTrue(
            isStringContain(
                '"description":"**encrypted**: true\n**info**: 123ABC\n**helper**: encryption method"',
                decodedMetadata
            )
        );

        // Set another images generator
        vm.startPrank(OWNER);
        imagesGenerator2 = new YiJingImagesGenerator();
        imagesGenerator2.init(address(metadataGenerator));
        metadataGenerator.setNewImagesGenerator(address(imagesGenerator2));
        vm.stopPrank();

        assertEq(metadataGenerator.getLastVersion(), 1);

        vm.mockCall(
            address(imagesGenerator2),
            abi.encodeWithSelector(imagesGenerator2.getNftImage.selector),
            abi.encode("data:image/svg+xml;base64,ENCODED_IMAGE")
        );

        metadata = metadataGenerator.getJsonMetadata(nftData);
        assertFalse(isEmptyString(metadata));
        assertEq(slice(1, 29, metadata), "data:application/json;base64,");

        decodedMetadata = string(Base64Std.decode(slice(30, bytes(metadata).length, metadata)));
        startPosition =
            getPositionStringContained("data:image/svg+xml;base64,", decodedMetadata) +
            26;
        encodedImage = slice(
            startPosition,
            findFirstCharPositionAfter('"', startPosition, decodedMetadata) - 1,
            decodedMetadata
        );
        assertTrue(isStringContain('"name":"Yi Jing Hexagram #1"', decodedMetadata));
        assertTrue(
            isStringContain(
                '"description":"**encrypted**: true\n**info**: 123ABC\n**helper**: encryption method"',
                decodedMetadata
            )
        );
        assertTrue(areStringsEquals(encodedImage, "ENCODED_IMAGE"));
    }
}
