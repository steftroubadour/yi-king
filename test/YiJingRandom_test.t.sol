// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { BaseTest } from "test/utils/BaseTest.sol";
import { YiJingRandom } from "src/YiJingRandom.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Bits } from "lib_personal/Bits.sol";
import { Strings as Strings2 } from "lib_personal/Strings.sol";
import { Arrays } from "lib_personal/Arrays.sol";

contract YiJingRandom_test is BaseTest {
    YiJingRandom random;

    function setUp() public {
        random = new YiJingRandom();

        assertTrue(IS_TEST);
    }

    function test_getNumbers() public {
        // series are not equals with a little variation of question
        string memory name = "moa";
        string memory question1 = "is it question 1 ?";
        bytes memory seed1 = abi.encode(keccak256(abi.encode(name, question1)));

        uint256 length = 6;
        uint256 min = 0;
        uint256 max = 3;

        uint8[] memory numbers1 = Arrays.toUint8Array(random.getNumbers(seed1, length, min, max));
        assertEq(numbers1.length, 6);

        string memory question2 = "is it question 2 ?";
        bytes memory seed2 = abi.encode(keccak256(abi.encode(name, question2)));

        uint8[] memory numbers2 = Arrays.toUint8Array(random.getNumbers(seed2, length, min, max));
        assertEq(numbers2.length, 6);

        assertFalse(Arrays.areEquals(numbers1, numbers2));

        // to compare arrays, we convert them in a number...
        uint256 number1 = Arrays.toNumber(numbers1);
        uint256 number2 = Arrays.toNumber(numbers2);

        assertTrue(number1 != number2);

        // ... or we can use Arrays.areEquals
        assertFalse(Arrays.areEquals(numbers1, numbers2));
    }
}
