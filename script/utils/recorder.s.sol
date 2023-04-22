// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Base } from "./base.s.sol";
import { Exporter } from "./exporter.s.sol";

abstract contract Recorder is Exporter {
    using Strings for uint256;
    using stdJson for string;

    /// @notice states
    string private _path;
    string private _contracts = "contracts";
    string private _setup = "setup";
    string private _json = "json";

    function initPath() internal returns (string memory networkAlias) {
        networkAlias = _getChainAlias();
        _path = string.concat("script/utils/", networkAlias, ".json");
    }

    /**
     * @notice Returns bytes memory to read with `abi.decode(rawJson,(types/Struct))`
     *
     * NOTE use Struct only if all types are the same
     */
    function readRecordKey(string memory key) internal view returns (bytes memory) {
        string memory file = vm.readFile(_path);
        return file.parseRaw(key);
    }

    function writeRecord(Setup memory setup) internal {
        vm.writeFile(_path, "");

        // write current contract address
        string memory index = "contracts";
        string memory serialized;

        serialized = index.serialize("YiJingRandom", address(random));
        serialized = index.serialize("YiJingImagesGenerator", address(imagesGenerator));
        serialized = index.serialize("Affiliation", address(affiliation));
        serialized = index.serialize("YiJingMetadataGenerator", address(metadataGenerator));
        serialized = index.serialize("YiJingNft", address(nft));

        _contracts = serialized;
        delete serialized;

        // write initial setup
        index = "setup";
        serialized = index.serialize("deployer", setup.deployer);
        serialized = index.serialize("contracts_owner", setup.contractsOwner);
        serialized = index.serialize("mint_price", setup.mintPrice);
        serialized = index.serialize("nft_is_paused", setup.nftIsPaused);
        serialized = index.serialize("deployment_tests_valid", setup.deploymentTestsValid);
        _setup = serialized;
        delete serialized;

        index = ".";
        serialized = index.serialize("setup", _setup);
        serialized = index.serialize("contracts", _contracts);
        serialized = index.serialize("chainId", block.chainid);
        serialized = index.serialize("chainAlias", _getChainAlias());
        serialized = index.serialize("contractsNames", contractsNames);
        _json = serialized;
        delete serialized;

        _json.write(_path);
    }
}
