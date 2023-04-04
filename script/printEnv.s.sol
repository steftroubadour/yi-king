// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./utils/recorder.s.sol";
import "forge-std/Test.sol";

contract printEnv is Recorder, Test {
    using Strings for address;

    function run() public {
        string memory networkAlias = initPath();
        string memory envPath = string.concat("./.env.", networkAlias);
        vm.writeFile(envPath, "# Environment file created by `printEnv`");
        vm.writeLine(envPath, " \n");

        Contracts memory c = abi.decode(readRecordKey(".contracts"), (Contracts));

        // contract address
        vm.writeLine(envPath, string.concat("NFTMetadataImage:", c.imageContract.toHexString()));
        vm.writeLine(envPath, string.concat("Random:", c.imageContract.toHexString()));
    }
}
