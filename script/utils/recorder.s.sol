// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "forge-std/StdJson.sol";

import "./base.s.sol";

abstract contract Recorder is Base {
    using Strings for uint256;
    using stdJson for string;

    struct InitialSetup {
        address deployer;
    }

    struct Contracts {
        address imageContract;
        address randomContract;
    }

    struct Network {
        Contracts deployed;
        InitialSetup initialSetup;
    }

    /// @notice states
    string internal path;
    string internal contracts = "contracts";
    string internal initialSetup = "initialSetup";
    string internal network = "network";

    function initPath() internal returns (string memory networkAlias) {
        networkAlias = _findNetworkAlias();
        path = string.concat("script/utils/", networkAlias, ".json");
    }

    // function loadNetworkState() internal {
    //     Contracts memory parsedContracts = abi.decode(readRecordKey(".contracts"),(Contracts))
    //     dao=
    // }

    /**
     * @notice Returns bytes memory to read with `abi.decode(rawJson,(types/Struct))`
     *
     * NOTE use Struct only if all types are the same
     */
    function readRecordKey(string memory key) internal view returns (bytes memory) {
        string memory file = vm.readFile(path);
        return file.parseRaw(key);
    }

    function writeRecord(string memory networkAlias, address deployer) internal {
        vm.writeFile(path, "");

        // write current contract address
        string memory index = "contractAddr";
        string memory serializedAt;

        serializedAt = index.serialize("YiJingImagesGenerator", address(imageContract));
        serializedAt = index.serialize("YiJingRandom", address(randomContract));

        contracts = serializedAt;

        // write initial setup
        index = "setup";
        delete serializedAt;
        serializedAt = index.serialize("deployer", deployer);

        initialSetup = serializedAt;

        index = ".";
        delete serializedAt;
        serializedAt = index.serialize("initialSetup", initialSetup);
        serializedAt = index.serialize("contracts", contracts);

        network = network.serialize(networkAlias, serializedAt);

        network.write(path);
    }

    function _findNetworkAlias() internal view returns (string memory) {
        uint256 chainId = block.chainid;
        if (chainId == 5) return "goerli";
        if (chainId == 31337) return "anvil";
        if (chainId == 1) return "mainnet";
        if (chainId == 11155111) return "sepolia";

        revert("Bad network!");
    }
}
