//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "forge-std/Test.sol";
import "./utils/recorder.s.sol";

contract Deployer is Script, Recorder, Test {
    string internal networkAlias;

    function run() public {
        // init path record and set alias network name
        networkAlias = initPath();

        // import `.env` private key
        uint256 privateKey = vm.envUint(string.concat("DEPLOYER_", networkAlias));
        DEPLOYER = vm.addr(privateKey);

        // logs info
        emit log_named_string("On network", string.concat(networkAlias));
        emit log_named_uint("Chain Id", block.chainid);
        emit log_named_uint("Block number", block.number);
        emit log_named_address("Start deploying with", DEPLOYER);
        emit log_named_uint("Balance", DEPLOYER.balance);

        // start deploying
        vm.startBroadcast(privateKey);
        delete privateKey;

        _0_deployNFTMetadataImage();
        _1_deployRandom();
        vm.stopBroadcast();

        // write record of deployed contracts
        writeRecord(networkAlias, DEPLOYER);
    }
}
