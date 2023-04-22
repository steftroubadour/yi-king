// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/recorder.s.sol";

contract printEnv is Recorder {
    using Strings for address;

    function run() public {
        string memory networkAlias = initPath();
        string memory envPath = string.concat("./.env.", networkAlias);
        vm.writeFile(envPath, "# Environment file created by `printEnv`");
        vm.writeLine(envPath, " \n");

        Contracts memory c = abi.decode(readRecordKey(".contracts"), (Contracts));

        // contract address
        vm.writeLine(
            envPath,
            string.concat("YiJingImagesGenerator:", c.imagesGenerator.toHexString())
        );
        vm.writeLine(envPath, string.concat("YiJingRandom:", c.imagesGenerator.toHexString()));
    }
}
