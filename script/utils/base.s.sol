// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { Script } from "forge-std/Script.sol";
import { Test } from "forge-std/Test.sol";

import { Affiliation } from "src/Affiliation.sol";
import { YiJingImagesGenerator } from "src/YiJingImagesGenerator.sol";
import { YiJingMetadataGenerator } from "src/YiJingMetadataGenerator.sol";
import { YiJingNft } from "src/YiJingNft.sol";
import { YiJingRandom } from "src/YiJingRandom.sol";
import { StringHelper } from "foundry-test-helpers/helper/StringHelper.sol";

abstract contract Base is Script, Test, StringHelper {
    using Strings for uint256;
    // internal contracts
    YiJingRandom random;
    YiJingImagesGenerator imagesGenerator;
    YiJingMetadataGenerator metadataGenerator;
    Affiliation affiliation;
    YiJingNft nft;

    struct Setup {
        address deployer;
        address contractsOwner;
        string mintPrice;
        bool nftIsPaused;
        bool deploymentTestsValid;
    }

    struct Contracts {
        address random;
        address imagesGenerator;
        address affiliation;
        address metadataGenerator;
        address nft;
    }

    struct Network {
        Contracts deployed;
        Setup setup;
    }

    // internal characters
    address internal DEPLOYER;
    string[] internal contractsNames;

    /* //////////////////////////
         DEPLOYMENT FUNCTIONS
    ////////////////////////// */
    ////// Step 0
    // YiJingRandom contract
    function _0_deployYiJingRandom() internal {
        random = new YiJingRandom();
        contractsNames.push("YiJingRandom");
    }

    ////// Step 1
    // YiJingImagesGenerator contract
    function _1_deployYiJingImagesGenerator() internal {
        imagesGenerator = new YiJingImagesGenerator();
        contractsNames.push("YiJingImagesGenerator");
    }

    // Affiliation contract
    function _1_deployAffiliation() internal {
        affiliation = new Affiliation();
        contractsNames.push("Affiliation");
    }

    ////// Step 2
    // YiJingMetadataGenerator contract
    function _2_deployYiJingMetadataGenerator() internal {
        metadataGenerator = new YiJingMetadataGenerator(address(imagesGenerator));
        contractsNames.push("YiJingMetadataGenerator");
    }

    ////// Step 3
    // YiJingNft contract
    function _3_deployYiJingNft() internal {
        nft = new YiJingNft(address(metadataGenerator), address(affiliation));
        contractsNames.push("YiJingNft");
    }

    ////// Step 4
    // Initialize contracts
    function _4_init() internal {
        imagesGenerator.init(address(metadataGenerator));
        affiliation.init(address(nft));

        nft.togglePause();
    }

    function _dataSetupRetriever() internal view returns (Setup memory) {
        return
            Setup(
                DEPLOYER,
                DEPLOYER,
                _weiToEther(nft.mintPrice()),
                nft.paused(),
                _deploymentTester()
            );
    }

    function _deploymentTester() internal view returns (bool) {
        // Are all not paused
        if (nft.paused()) return false;
        if (affiliation.paused()) return false;
        if (imagesGenerator.paused()) return false;

        // Have all the same owner
        address owner = nft.owner();
        if (affiliation.owner() != owner) return false;
        if (imagesGenerator.owner() != owner) return false;
        if (metadataGenerator.owner() != owner) return false;
        return true;
    }

    function _weiToEther(uint inWei) internal pure returns (string memory) {
        uint bps = (inWei * 10000) / 1 ether;
        uint intPart = bps / 10000;
        uint decPart = bps - intPart * 10000;

        if (decPart == 0) return string.concat(intPart.toString(), " ETH");
        else {
            // prepend zeros
            uint decPartLength = bytes(decPart.toString()).length;
            string memory decPrefix = decPartLength == 1
                ? "000"
                : (decPartLength == 2 ? "00" : (decPartLength == 3 ? "0" : ""));
            return string.concat(intPart.toString(), ".", decPrefix, decPart.toString(), " ETH");
        }
    }

    function _getChainAlias() internal view returns (string memory) {
        uint256 chainId = block.chainid;
        if (chainId == 5) return "goerli";
        if (chainId == 31337) return "anvil";
        if (chainId == 1) return "mainnet";
        if (chainId == 11155111) return "sepolia";

        revert("Bad network!");
    }

    function getChainId(string memory chainAlias) internal pure returns (string memory) {
        if (areStringsEquals(chainAlias, "goerli")) return "5";
        if (areStringsEquals(chainAlias, "anvil")) return "31337";
        if (areStringsEquals(chainAlias, "mainnet")) return "1";
        if (areStringsEquals(chainAlias, "sepolia")) return "11155111";

        revert("Bad network!");
    }

    function _getAddress(string memory contractName) internal view returns (address) {
        if (areStringsEquals(contractName, "YiJingNft")) return address(nft);
        if (areStringsEquals(contractName, "YiJingRandom")) return address(random);
        if (areStringsEquals(contractName, "YiJingImagesGenerator"))
            return address(imagesGenerator);
        if (areStringsEquals(contractName, "YiJingMetadataGenerator"))
            return address(metadataGenerator);
        if (areStringsEquals(contractName, "Affiliation")) return address(affiliation);
        return address(0);
    }

    function isStringContain(string memory what, string memory where) public pure returns (bool) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return true;
        }

        return false;
    }

    function getPositionStringContained(
        string memory what,
        string memory where
    ) public pure returns (uint256) {
        uint256 whatBytesLength = bytes(what).length;
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = 0; i <= whereBytesLength - whatBytesLength; i++) {
            if (areStringsEquals(slice(i + 1, i + whatBytesLength, where), what)) return i + 1;
        }

        return 0;
    }

    function findFirstCharPositionAfter(
        string memory char,
        uint256 startPosition,
        string memory where
    ) public pure returns (uint256) {
        require(bytes(char).length == 1 && startPosition != 0);
        uint256 whereBytesLength = bytes(where).length;

        for (uint256 i = startPosition - 1; i < whereBytesLength - 1; i++) {
            if (areStringsEquals(slice(i + 1, i + 1, where), char)) return i + 1;
        }

        return 0;
    }
}
