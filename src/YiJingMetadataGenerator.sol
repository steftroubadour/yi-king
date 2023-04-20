// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IYiJingImagesGenerator } from "src/interface/IYiJingImagesGenerator.sol";
import { IYiJingBase } from "src/interface/IYiJingBase.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title images for Yi Jing App & NFT
contract YiJingMetadataGenerator is IYiJingBase, Ownable {
    using Strings for uint256;
    using Strings for uint64;

    address public imagesGenerator;

    constructor(address imagesGenerator_) {
        imagesGenerator = imagesGenerator_;
    }

    /*/////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    //////////////////////////////////////////////////// */

    /// Retrieve base64 hexagram image for a variation
    /// @param nftData nft data
    /// @return string nft metadata
    function getJsonMetadata(NftDataExtended memory nftData) external view returns (string memory) {
        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(
                    abi.encodePacked(
                        "{",
                        '"name":"Yi Jing Hexagram #',
                        nftData.tokenId.toString(),
                        '",',
                        '"description":"',
                        _getMetadataDescription(nftData),
                        '",',
                        '"image":"',
                        IYiJingImagesGenerator(imagesGenerator).getNftImage(nftData.hexagram.lines),
                        '",',
                        '"background_color":"0f234f",',
                        '"attributes":"',
                        _getMetadataAttributes(nftData),
                        '"}'
                    )
                )
            );
    }

    function setImagesGenerator(address imagesGenerator_) public onlyOwner {
        imagesGenerator = imagesGenerator_;
    }

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/
    /// Retrieve metadata attributes
    /// @param nftData nft data
    /// @return bytes nft metadata attributes
    function _getMetadataAttributes(
        NftDataExtended memory nftData
    ) internal pure returns (string memory) {
        return
            string.concat(
                '[{"display_type":"date","trait_type":"Created","value":',
                nftData.date.toString(),
                "}]"
            );
    }

    /// Retrieve metadata description with information
    /// @param nftData nft data
    /// @return bytes nft metadata description
    function _getMetadataDescription(
        NftDataExtended memory nftData
    ) internal pure returns (string memory) {
        return
            string.concat(
                "**encrypted**: ",
                nftData.encrypted ? "true" : "false",
                "\n**info**: ",
                nftData.info,
                "\n**helper**: ",
                nftData.encryptionHelperMessage
            );
    }
}
