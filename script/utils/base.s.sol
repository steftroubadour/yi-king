// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/NFTMetadataImage.sol";
import "src/Random.sol";

abstract contract Base is Script {
    // internal contracts
    NFTMetadataImage internal imageContract;
    Random internal randomContract;

    // internal characters
    address internal DEPLOYER;

    /* //////////////////////////
         DEPLOYMENT FUNCTIONS
    ////////////////////////// */

    // NFTMetadataImage contract
    function _0_deployNFTMetadataImage() internal {
        imageContract = new NFTMetadataImage();
    }

    // Random contract
    function _1_deployRandom() internal {
        randomContract = new Random();
    }
}
