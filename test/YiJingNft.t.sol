// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest, Arrays, Bits, console } from "test/utils/BaseTest.sol";
import { Base64Std } from "test/utils/Base64Std.sol";
import { YiJingImagesGenerator } from "src/YiJingImagesGenerator.sol";
import { YiJingMetadataGenerator } from "src/YiJingMetadataGenerator.sol";
import { YiJingNft, IYiJingBase } from "src/YiJingNft.sol";
import { Affiliation } from "src/Affiliation.sol";
import { IAffiliation } from "src/interface/IAffiliation.sol";

contract YiJingNft_test is BaseTest {
    Affiliation affiliation;
    YiJingNft nft;
    YiJingImagesGenerator imagesGenerator;
    YiJingMetadataGenerator metadataGenerator;

    function setUp() public {
        assertTrue(IS_TEST);

        vm.startPrank(DEPLOYER);
        imagesGenerator = new YiJingImagesGenerator();
        metadataGenerator = new YiJingMetadataGenerator(address(imagesGenerator));
        affiliation = new Affiliation();
        nft = new YiJingNft(address(metadataGenerator), address(affiliation));

        // init
        imagesGenerator.init(address(metadataGenerator));
        affiliation.init(address(nft));
        nft.togglePause();
        vm.stopPrank();

        OWNER = DEPLOYER;

        // Add an affiliate
        vm.prank(OWNER);
        affiliation.add(AN_AFFILIATE, 500);
    }

    function testSetUp() public {
        assertEq(metadataGenerator.getLastVersion(), 0);
        assertEq(nft.metadataGenerator(), address(metadataGenerator));
        assertEq(nft.getAffiliation(), address(affiliation));
        assertEq(imagesGenerator.getCaller(), address(metadataGenerator));
        assertEq(affiliation.getCaller(), address(nft));
        assertFalse(affiliation.paused());
        assertFalse(imagesGenerator.paused());
        assertFalse(nft.paused());

        assertEq(nft.mintPrice(), 0.001 ether);
        assertEq(address(nft).balance, 0);
    }

    /*////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    function testModifyEncryptedInfo() public {
        _mintOneToken(AN_USER, AN_AFFILIATE);

        string memory tokenUri = nft.tokenURI(1);
        string memory decodedMetadata = string(
            Base64Std.decode(slice(30, bytes(tokenUri).length, tokenUri))
        );
        uint startPosition = getPositionStringContained(
            "data:image/svg+xml;base64,",
            decodedMetadata
        ) + 26;
        string memory oldEncodedImage = slice(
            startPosition,
            findFirstCharPositionAfter('"', startPosition, decodedMetadata) - 1,
            decodedMetadata
        );

        assertTrue(isStringContain('"name":"Yi Jing Hexagram #1"', decodedMetadata));
        assertTrue(
            isStringContain(
                '"description":"**encrypted**: true\n**info**: 123ABC\n**helper**: private key"',
                decodedMetadata
            )
        );

        vm.expectRevert("NFT: not owner of");
        nft.modifyEncryptedInfo(1, "123AZE", "an helper message");

        vm.prank(AN_USER);
        nft.modifyEncryptedInfo(1, "123AZE", "an helper message");

        string memory newTokenUri = nft.tokenURI(1);
        string memory newDecodedMetadata = string(
            Base64Std.decode(slice(30, bytes(tokenUri).length, newTokenUri))
        );
        startPosition =
            getPositionStringContained("data:image/svg+xml;base64,", newDecodedMetadata) +
            26;
        string memory newEncodedImage = slice(
            startPosition,
            findFirstCharPositionAfter('"', startPosition, newDecodedMetadata) - 1,
            newDecodedMetadata
        );
        assertFalse(areStringsEquals(tokenUri, newTokenUri));
        assertTrue(areStringsEquals(oldEncodedImage, newEncodedImage));
        assertTrue(isStringContain('"name":"Yi Jing Hexagram #1"', newDecodedMetadata));
        assertTrue(
            isStringContain(
                '"description":"**encrypted**: true\n**info**: 123AZE\n**helper**: an helper message"',
                newDecodedMetadata
            )
        );
    }

    function testMint() public {
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        IYiJingBase.NftData memory nftData = IYiJingBase.NftData(
            IYiJingBase.Hexagram(lines),
            1234567890,
            true,
            "123ABC",
            "private key"
        );

        uint256 mintPrice = nft.mintPrice();

        vm.deal(AN_USER, 1000 ether);
        uint256 balance = AN_USER.balance;
        uint256 affiliationTotalBalance = affiliation.getTotalBalance();

        // mint without affiliate
        vm.prank(AN_USER);
        nft.mint{ value: mintPrice }(nftData, address(0));

        assertEq(nft.ownerOf(1), AN_USER);
        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(2);
        assertEq(AN_USER.balance, balance - mintPrice); // 0 gas fee
        assertEq(affiliation.getTotalBalance(), affiliationTotalBalance);
        assertGt(address(nft).balance, 0);

        affiliationTotalBalance = affiliation.getTotalBalance();
        uint256 affiliateBalance = affiliation.getData(AN_AFFILIATE).balance;
        vm.deal(ANOTHER_USER, 1000 ether);
        balance = ANOTHER_USER.balance;

        // mint with affiliate
        vm.prank(ANOTHER_USER);
        nft.mint{ value: mintPrice }(nftData, AN_AFFILIATE);

        assertEq(nft.ownerOf(2), ANOTHER_USER);
        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(3);
        assertEq(ANOTHER_USER.balance, balance - mintPrice); // 0 gas fee
        assertGt(affiliation.getTotalBalance(), affiliationTotalBalance);
        assertGt(affiliation.getData(AN_AFFILIATE).balance, affiliateBalance);

        // test requirements
        vm.prank(OWNER);
        nft.togglePause();

        vm.prank(ANOTHER_USER);
        vm.expectRevert("Pausable: paused");
        nft.mint{ value: mintPrice }(nftData, AN_AFFILIATE);

        vm.prank(OWNER);
        nft.togglePause();

        vm.prank(ANOTHER_USER);
        vm.expectRevert("NFT: value too small");
        nft.mint{ value: mintPrice - 1 wei }(nftData, AN_AFFILIATE);
    }

    function testBurn() public {
        uint256 mintPrice = nft.mintPrice();
        IYiJingBase.NftData memory nftData = _mintOneToken(AN_USER, AN_AFFILIATE);
        assertEq(nft.ownerOf(1), AN_USER);

        vm.prank(AN_USER);
        nft.burn(1);

        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(1);
        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(2);

        vm.deal(ANOTHER_USER, 1000 ether);
        vm.prank(ANOTHER_USER);
        nft.mint{ value: mintPrice }(nftData, AN_AFFILIATE);
        assertEq(nft.ownerOf(2), ANOTHER_USER);

        ///////// test requirements ////////
        vm.prank(OWNER);
        nft.togglePause();

        // whenNotPaused
        vm.prank(ANOTHER_USER);
        vm.expectRevert("Pausable: paused");
        nft.burn(2);

        vm.prank(OWNER);
        nft.togglePause();

        // _isApprovedOrOwner
        vm.prank(AN_USER);
        vm.expectRevert("NFT: not owner or approved");
        nft.burn(2);
    }

    function testTokenURI() public {
        _mintOneToken(AN_USER, AN_AFFILIATE);

        string memory tokenUri = nft.tokenURI(1);
        string memory decodedMetadata = string(
            Base64Std.decode(slice(30, bytes(tokenUri).length, tokenUri))
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
        string memory decodedImage = string(Base64Std.decode(encodedImage));

        assertTrue(isStringContain('"name":"Yi Jing Hexagram #1"', decodedMetadata));
        assertTrue(
            isStringContain(
                '"description":"**encrypted**: true\n**info**: 123ABC\n**helper**: private key"',
                decodedMetadata
            )
        );
        assertTrue(
            isStringContain(
                '"attributes":"[{"display_type":"date","trait_type":"Created","value":1234567890}]"}',
                decodedMetadata
            )
        );
        assertTrue(
            isStringContain(
                '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"',
                decodedImage
            )
        );
        assertTrue(
            isStringContain(
                '<mpath xlink:href="#yijing"/></animateMotion></path></svg>',
                decodedImage
            )
        );

        // Set another images generator
        vm.startPrank(OWNER);
        YiJingImagesGenerator imagesGenerator2 = new YiJingImagesGenerator();
        imagesGenerator2.init(address(metadataGenerator));
        metadataGenerator.setNewImagesGenerator(address(imagesGenerator2));
        vm.stopPrank();

        assertEq(metadataGenerator.getLastVersion(), 1);

        vm.mockCall(
            address(imagesGenerator2),
            abi.encodeWithSelector(imagesGenerator2.getNftImage.selector),
            abi.encode("data:image/svg+xml;base64,ENCODED_IMAGE")
        );

        string memory newMetadata = nft.tokenURI(1);
        string memory metadata_v0 = nft.tokenURI(1, 0);
        string memory metadata_v1 = nft.tokenURI(1, 1);
        assertFalse(areStringsEquals(tokenUri, newMetadata));
        assertFalse(areStringsEquals(metadata_v0, metadata_v1));
        assertTrue(areStringsEquals(metadata_v0, tokenUri));
        assertTrue(areStringsEquals(metadata_v1, newMetadata));
    }

    function testSetMintPrice() public {
        uint256 mintPrice = 0.8 ether;

        vm.prank(OWNER);
        nft.setMintPrice(mintPrice);

        assertEq(nft.mintPrice(), mintPrice);

        ///////// test requirements ////////
        // onlyOwner
        vm.prank(AN_USER);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.setMintPrice(mintPrice);
    }

    function testSetMetadataGenerator() public {
        vm.prank(OWNER);
        nft.setMetadataGenerator(A_CONTRACT);

        assertEq(nft.metadataGenerator(), A_CONTRACT);

        ///////// test requirements ////////
        // onlyOwner
        vm.prank(AN_USER);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.setMetadataGenerator(A_CONTRACT);
    }

    function testSetAffiliation() public {
        vm.prank(OWNER);
        nft.setAffiliation(A_CONTRACT);

        assertEq(nft.getAffiliation(), A_CONTRACT);

        ///////// test requirements ////////
        // onlyOwner
        vm.prank(AN_USER);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.setAffiliation(A_CONTRACT);
    }

    function testWithdraw() public {
        _mintOneToken(AN_USER, AN_AFFILIATE);

        uint256 nftBalance = address(nft).balance;
        uint256 ownerBalance = OWNER.balance;
        uint256 affiliatesTotalBalance = affiliation.getTotalBalance();

        vm.prank(OWNER);
        nft.withdraw();

        assertLt(address(nft).balance, nftBalance);
        assertFalse(address(nft).balance == 0);
        assertGt(OWNER.balance, ownerBalance);
        assertEq(OWNER.balance - ownerBalance, nftBalance - affiliatesTotalBalance);

        ///////// test requirements ////////
        // onlyOwner
        vm.prank(AN_USER);
        vm.expectRevert("Ownable: caller is not the owner");
        nft.withdraw();
    }

    function testAffiliateWithdraw() public {
        _mintOneToken(AN_USER, AN_AFFILIATE);

        uint256 nftBalance = address(nft).balance;
        uint256 affiliateBalance = AN_AFFILIATE.balance;
        uint256 affiliatesTotalBalance = affiliation.getTotalBalance();
        uint256 affiliateBalanceInContract = affiliation.getData(AN_AFFILIATE).balance;

        vm.prank(AN_AFFILIATE);
        nft.affiliateWithdraw();

        assertEq(nftBalance - address(nft).balance, affiliateBalanceInContract);
        assertFalse(address(nft).balance == 0);
        assertEq(affiliation.getData(AN_AFFILIATE).balance, 0);
        assertEq(AN_AFFILIATE.balance - affiliateBalance, affiliateBalanceInContract);
        assertEq(
            affiliatesTotalBalance - affiliation.getTotalBalance(),
            affiliateBalanceInContract
        );

        ///////// test requirements ////////
        // affiliate not exist
        vm.prank(AN_USER);
        vm.expectRevert("Affiliation: not exists");
        nft.affiliateWithdraw();
    }

    function _mintOneToken(
        address to,
        address affiliate
    ) internal returns (IYiJingBase.NftData memory) {
        uint256 mintPrice = nft.mintPrice();
        uint8[6] memory lines = [3, 1, 2, 3, 0, 1]; // i.e. [9, 7, 8, 9, 6, 7]
        IYiJingBase.NftData memory nftData = IYiJingBase.NftData(
            IYiJingBase.Hexagram(lines),
            1234567890,
            true,
            "123ABC",
            "private key"
        );
        vm.deal(to, 1000 ether);
        vm.prank(to);
        nft.mint{ value: mintPrice }(nftData, affiliate);

        return nftData;
    }
}
