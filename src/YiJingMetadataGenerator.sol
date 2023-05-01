// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IYiJingImagesGenerator } from "src/interface/IYiJingImagesGenerator.sol";
import { IYiJingBase } from "src/interface/IYiJingBase.sol";

/**
 * @author Stephane Chaunard <linktr.ee/stephanechaunard>
 * @title images for Yi Jing App & NFT
 */
contract YiJingMetadataGenerator is IYiJingBase, Ownable {
    using Strings for uint256;
    using Strings for uint64;

    address[] private imagesGenerators;

    constructor(address imagesGenerator) {
        imagesGenerators.push(imagesGenerator);
    }

    /*/////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    //////////////////////////////////////////////////// */

    /** Get JSON metadata
     * @param nftData nft data
     * @return string nft metadata
     */
    function getJsonMetadata(NftDataExtended memory nftData) external view returns (string memory) {
        return _getJsonMetadata(nftData, this.getLastVersion());
    }

    /** Get JSON metadata
     * @param nftData nft data
     * @param version start from 0
     * @return string nft metadata
     */
    function getJsonMetadata(
        NftDataExtended memory nftData,
        uint256 version
    ) external view returns (string memory) {
        require(version <= this.getLastVersion(), "Metadata: wrong version");
        return _getJsonMetadata(nftData, version);
    }

    /** Get last version
     * @return uint256 version
     */
    function getLastVersion() external view returns (uint256) {
        return imagesGenerators.length - 1;
    }

    /** Set new images generator, older is kept
     * @param imagesGenerator images generator address
     * Requirements:
     * - caller must be owner
     */
    function setNewImagesGenerator(address imagesGenerator) public onlyOwner {
        imagesGenerators.push(imagesGenerator);
    }

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/

    /** Get JSON metadata
     * @param nftData nft data
     * @param version start from 0
     * @return string nft metadata
     */
    function _getJsonMetadata(
        NftDataExtended memory nftData,
        uint256 version
    ) internal view returns (string memory) {
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
                        IYiJingImagesGenerator(imagesGenerators[version]).getNftImage(
                            nftData.hexagram.lines
                        ),
                        '",',
                        '"background_color":"0f234f",',
                        '"attributes":"',
                        _getMetadataAttributes(nftData),
                        '"}'
                    )
                )
            );
    }

    /**
     * @param nftData nft data
     * @return bytes nft metadata attributes
     */
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

    /**
     * @param nftData nft data
     * @return bytes nft metadata description
     */
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
