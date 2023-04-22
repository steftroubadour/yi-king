// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Base } from "./base.s.sol";

abstract contract Exporter is Base {
    using Strings for uint256;
    using stdJson for string;

    struct Contract {
        address contractAddress;
        string abi;
    }

    /// @notice states
    string internal _contractJson;

    function _readRecordKey(
        string memory key,
        string memory path
    ) internal view returns (bytes memory) {
        string memory json = vm.readFile(path);
        return json.parseRaw(key);
    }

    function _retrieveAbi(string memory contractName) internal view returns (string memory) {
        string memory path = string.concat("out/", contractName, ".sol/", contractName, ".json");
        string memory json = vm.readFile(path);
        uint256 startPosition = getPositionStringContained('"abi": [', json) + 7;
        uint256 endPosition = getPositionStringContained('],\n  "bytecode": {', json);
        return slice(startPosition, endPosition, json);
    }

    function exportTo(string memory exportPath, string[] memory chainsAliasToExport) internal {
        string memory chainPath = string.concat("script/utils/", _getChainAlias(), ".json");
        string memory chainJson = vm.readFile(chainPath);
        string[] memory contractsNames = chainJson.readStringArray(".contractsNames");

        string memory contractName;
        string memory path;
        string memory chain;
        string memory serialized;
        string memory index;
        string memory json;
        string memory jsonIndex; // = "."; to study
        for (uint i = 0; i < contractsNames.length; i++) {
            contractName = contractsNames[i];
            path = string.concat(exportPath, contractName, ".json");
            vm.writeFile(path, "");

            for (uint n = 0; n < chainsAliasToExport.length; n++) {
                chainPath = string.concat("script/utils/", chainsAliasToExport[n], ".json");
                chainJson = vm.readFile(chainPath);

                index = getChainId(chainsAliasToExport[n]);
                serialized = index.serialize("chainName", chainsAliasToExport[n]);
                serialized = index.serialize(
                    "contractAddress",
                    chainJson.readString(string.concat(".contracts.", contractName))
                );
                serialized = index.serialize("deployer", chainJson.readString(".setup.deployer"));
                chain = serialized;
                delete serialized;
                json = jsonIndex.serialize(index, chain);
                delete chain;
                delete index;
            }

            json = jsonIndex.serialize("contractAbi", _retrieveAbi(contractName));

            json.write(path);
            delete jsonIndex;
            delete json;
        }
    }
}
