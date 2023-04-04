// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Random {
    // Add other contract call option
    // Add chainlink VRF option

    // Be careful to pass a seed value that differ with little variation
    // Example:
    // seed = abi.encode(name, question) is not enough
    // prefer seed = abi.encode(keccak256(abi.encode(name, question)))
    // the first bytes must change if question change !
    function getNumbers(
        bytes memory seed,
        uint256 length,
        uint256 min,
        uint256 max
    ) external view returns (uint256[] memory) {
        uint256[] memory numbers = new uint256[](length);
        bytes32 word = keccak256(
            abi.encode(block.timestamp, block.difficulty, block.number, block.basefee, tx.gasprice)
        );
        uint256 seedLength = seed.length;

        for (uint256 count; count < length; count++) {
            word = keccak256(abi.encode(word, seed[count % seedLength]));
            numbers[count] = (uint256(word) % (max - min + 1)) + min;
        }

        return numbers;
    }
}