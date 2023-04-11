// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { Test } from "forge-std/Test.sol";
import { RandomHelper } from "lib_personal/helper/RandomHelper.sol";
import { FuzzRecorder } from "lib_personal/recorder/FuzzRecorder.sol";

contract RandomHelper_Test is Test, RandomHelper, FuzzRecorder {
    function setUp() public {
        assertTrue(IS_TEST);

        _writeNewFile("test.txt", "");
    }

    function test_getRandomNumber(uint256 min, uint256 max) public {
        min = bound(min, 0, 1000);
        max = bound(max, min, 10 ** 9);
        uint256 randomNumber = _getRandomNumber(min, max);
        assertGe(randomNumber, min);
        assertLe(randomNumber, max);
    }

    // Test random cases without forge fuzz test
    // can have a problem if maxIterationsCount = 1000 'Reason: EvmError: OutOfGas'. How to increase limit ?
    /*function test_getDifferentRandomNumbers() public {
        uint256 maxDifferentNumbers = 100;
        uint256 n;
        uint256 min;
        uint256 max;

        uint256 maxIterationsCount = 256;
        for (uint256 count; count < maxIterationsCount; count++) {
            if (count == 0) {
                n = 5;
                min = 0;
                max = 1000;
            } else {
                n = _getRandomNumber(5, maxDifferentNumbers);
                min = _getRandomNumber(0, 1000);
                max = _getRandomNumber(min + maxDifferentNumbers, 10**6);
            }

            uint256[] memory randomNumbers = _getDifferentRandomNumbers(n, min, max);

            bool isAlreadyPresent;

            for (uint256 i; i < randomNumbers.length; i++) {
                for (uint256 j; j < randomNumbers.length; j++) {
                    if (j == i) continue;
                    if (randomNumbers[i] == randomNumbers[j]) {
                        isAlreadyPresent = true;
                    }
                }
            }

            assertFalse(isAlreadyPresent);
            //console.log("=======================================");
        }
    }*/

    /*function test_getDifferentRandomNumbers_init() public {
        _writeNewFile("test.txt", "");
    }*/

    // fuzz test doesn't work !
    function test_getDifferentRandomNumbers_test(uint256 n, uint256 min, uint256 max) public {
        uint256 maxDifferentNumbers = 20;
        n = bound(n, 5, maxDifferentNumbers);
        min = bound(min, 0, 1000);
        // ensure enough large range between min and max : min + maxDifferentNumbers * 10
        max = bound(max, min + maxDifferentNumbers * 10, 10 ** 6);

        // To debug fuzz test
        _writeNewLine("test.txt", "==============================");
        _writeNewLine("test.txt", string.concat("n: ", vm.toString(n)));
        _writeNewLine("test.txt", string.concat("min: ", vm.toString(min)));
        _writeNewLine("test.txt", string.concat("max: ", vm.toString(max)));
        _writeNewLine("test.txt", "==============================");

        uint256[] memory randomNumbers = _getDifferentRandomNumbers(n, min, max);

        // to stop fuzz test
        //assertTrue(randomNumbers[0] <= min + ((max - min) * 20) / 100);

        //emit log_named_array("randomNumbers", randomNumbers);
        //emit log_named_uint("randomNumbers[0]", randomNumbers[0]);

        bool isAlreadyPresent;

        for (uint256 i; i < randomNumbers.length; i++) {
            for (uint256 j; j < randomNumbers.length; j++) {
                if (j == i) continue;
                if (randomNumbers[i] == randomNumbers[j]) {
                    isAlreadyPresent = true;
                }
            }
        }

        assertFalse(isAlreadyPresent);
    }
}
