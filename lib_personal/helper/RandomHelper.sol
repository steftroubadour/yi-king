// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Test } from "forge-std/Test.sol";
import { TestHelper } from "./TestHelper.sol";
import { Strings } from "../Strings.sol";

abstract contract RandomHelper is Test, TestHelper {
    function _getRandomNumber(uint256 min, uint256 max) internal returns (uint256) {
        // Works with ffi=true in foundry.toml
        // Called two times in the same function, results will be differents, not true with $RANDOM
        // Problem: Sometimes vm.ffi() with 'shuf' returns bytes of digits between 0x30 and 0x39
        // and other times, it returns bytes with the number in it as "0x59" !
        // To resolve that, we do two cases and insure that the returned number is in the right range.

        //!\ May be enlarged shuf range and after use bound with the right range

        //!\ For a better distribution of small random numbers see BaseTest::_mintRandomTokensByUsers L44
        // to test

        string[] memory inputs = new string[](4);
        inputs[0] = "shuf";
        inputs[1] = "-i";
        inputs[2] = string.concat(vm.toString(min), "-", vm.toString(max));
        inputs[3] = "-n1";

        bytes memory result = vm.ffi(inputs);

        // Test if bytes are bytes of digits (between 0x30 and 0x39) or not
        bool areAllBytesNumbers = false;
        uint256 bytesNumbersCount;
        for (uint256 i = 0; i < result.length; i++) {
            if (result[i] >= 0x30 && result[i] <= 0x39) bytesNumbersCount++;
        }

        if (bytesNumbersCount == result.length) areAllBytesNumbers = true;

        uint256 randomNumber = areAllBytesNumbers
            ? vm.parseUint(string(result)) // - result is bytes of digits , we use 'string(result)' ex: 0x313435 => "145"
            : vm.parseUint(Strings.remove0x(vm.toString(result))); // - result is not, we use '_remove0x(vm.toString(result))' ex: 0x75 => "0x75" => "75"

        // insure that the returned number is in the right range.
        return bound2(randomNumber, min, max);
    }

    function _getDifferentRandomNumbers(
        uint256 n,
        uint256 min,
        uint256 max
    ) internal returns (uint256[] memory) {
        uint256[] memory tempNumbers = new uint256[](n);

        //_writeNewLine("test.txt", "_getDifferentRandomNumbers()");

        for (uint256 i; i < n; i++) {
            uint256 randomNumber;
            bool isAlreadyPresent = true;

            while (isAlreadyPresent) {
                isAlreadyPresent = false;
                randomNumber = _getRandomNumber(min, max);
                /*_writeNewLine(
                    "test.txt",
                    string.concat(
                        "randomNumber for i=",
                        vm.toString(i),
                        " : ",
                        vm.toString(randomNumber)
                    )
                );*/
                //console.log("randomNumber");
                //console.log(randomNumber);
                for (uint256 j; j < i; j++) {
                    /*_writeNewLine(
                        "test.txt",
                        string.concat(
                            "tempNumbers[",
                            vm.toString(j),
                            "] = ",
                            vm.toString(tempNumbers[j])
                        )
                    );*/
                    if (randomNumber == tempNumbers[j]) {
                        isAlreadyPresent = true;
                        break;
                    }
                }
            }

            tempNumbers[i] = randomNumber;
        }

        return tempNumbers;
    }
}
