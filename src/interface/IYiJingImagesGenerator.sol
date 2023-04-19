// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title Interface for images generator
interface IYiJingImagesGenerator {
    function getHexagramImageForVariation(
        uint8[6] calldata,
        uint8
    ) external pure returns (uint256, string memory);

    function getNftImage(uint8[6] memory) external pure returns (string memory);
}
