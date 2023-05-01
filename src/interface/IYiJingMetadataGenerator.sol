// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { IYiJingBase } from "src/interface/IYiJingBase.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title Interface for metadata generator contract
interface IYiJingMetadataGenerator is IYiJingBase {
    function getJsonMetadata(NftDataExtended memory) external pure returns (string memory);

    function getJsonMetadata(NftDataExtended memory, uint256) external pure returns (string memory);

    function getLastVersion() external pure returns (uint256);

    function setNewImagesGenerator(address) external;
}
