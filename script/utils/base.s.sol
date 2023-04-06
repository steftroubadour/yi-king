// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "src/YiJingImagesGenerator.sol";
import "src/YiJingRandom.sol";

abstract contract Base is Script {
    // internal contracts
    YiJingImagesGenerator internal imageContract;
    YiJingRandom internal randomContract;

    // internal characters
    address internal DEPLOYER;

    /* //////////////////////////
         DEPLOYMENT FUNCTIONS
    ////////////////////////// */

    // YiJingImagesGenerator contract
    function _0_deployYiJingImagesGenerator() internal {
        imageContract = new YiJingImagesGenerator();
    }

    // YiJingRandom contract
    function _1_deployYiJingRandom() internal {
        randomContract = new YiJingRandom();
    }
}
