// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/Strings.sol";
import "forge-std/Test.sol";
import "src/NFT721.sol";
import "./BaseTest.sol";

contract BaseTest_Test is BaseTest {
    uint256 runs;

    function setUp() public {
        _deployNFT();

        runs = _readFoundryTomlValue("[fuzz]", "runs");

        // To use VarRecorder
        _initialiseStorages();
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
        /*_writeNewLine("test.txt", "==============================");
        _writeNewLine("test.txt", string.concat("n: ", vm.toString(n)));
        _writeNewLine("test.txt", string.concat("min: ", vm.toString(min)));
        _writeNewLine("test.txt", string.concat("max: ", vm.toString(max)));
        _writeNewLine("test.txt", "==============================");*/

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

    function test_isMintedToken() public {
        uint256 tokenId = 19;

        assertFalse(_isMintedToken(tokenId));

        _setStatus(NFT721.SaleStatus.OpenSale);
        tokenId = 19;

        uint256 tokenPrice = nft.getMintPrice(19);
        vm.deal(A_USER, 1000 ether);
        vm.prank(A_USER);
        nft.mintOpen{ value: tokenPrice }(19);

        assertTrue(_isMintedToken(tokenId));
    }

    function test_retrieveOneNonMintedAndNonBurnedToken(uint256 randomNumber) public {
        assertGe(randomNumber, 0);

        uint256 tokenId = _retrieveOneNonMintedAndNonBurnedToken(TEAM_TOKENS + 1, MAX_TOKEN_SUPPLY);

        assertFalse(nft.isBurned(tokenId));

        vm.expectRevert("ERC721: invalid token ID");
        nft.ownerOf(tokenId);

        assertGt(tokenId, TEAM_TOKENS);
        assertLe(tokenId, MAX_TOKEN_SUPPLY);
    }

    function test_incrementUintVar() public {
        _initializeUintVar(testStorages[1], 0);
        for (uint256 i; i < runs; i++) {
            _incrementUintVar(testStorages[1]);
        }

        assertEq(_readUintVar(testStorages[1]), runs);

        vm.removeFile(_getVarPath(testStorages[1]));
    }

    function test_incrementUintVar(uint256 randomNumber) public {
        assertEq(randomNumber, randomNumber);

        string memory uintVar = testStorages[2];
        if (_isVarExist(uintVar)) {
            uint256 oldValue = _readUintVar(uintVar);
            _incrementUintVar(uintVar);
            uint256 newValue = _readUintVar(uintVar);

            assertTrue(newValue == oldValue + 1);
        } else {
            // a way to do something one time in a fuzz test
            // But it takes a round of the fuzz ! runs - 1
            // Initialize when file doesn't exists
            _initializeUintVar(uintVar, 0);
        }

        // End of the fuzz test
        if (_readUintVar(uintVar) == runs - 1) {
            _removeVar(uintVar);
        }
    }

    function test_initializeUintVar(uint256 number) public {
        // Example of usage of a fuzz counter
        // - Permit an initialization of fuzz test
        // - Permit to make stuff after the last iteration of the fuzz test
        // use an unused counter each time.
        string memory fuzzCounter = fuzzStorages[0];

        string memory uintVar = testStorages[0];
        if (_isVarExist(fuzzCounter)) {
            uint256 value = bound(number, 0, 1000);
            _initializeUintVar(uintVar, value);
            assertTrue(_readUintVar(uintVar) == value);

            _incrementUintVar(fuzzCounter);
        } else {
            // a way to do something one time in a fuzz test
            // But it takes a round of the fuzz ! runs - 1
            // Initialize when file doesn't exists
            _initializeUintVar(fuzzCounter, 0);
        }

        // Remove files at the end of the fuzz test
        if (_readUintVar(fuzzCounter) == runs - 1) {
            _removeVar(fuzzCounter);

            // remove var used
            _removeVar(uintVar);
        }
    }

    function test_storeUintVar() public {
        string memory myStorage = testStorages[3];
        assertFalse(_isStorageInUse(myStorage));
        string[] memory keys = new string[](2);
        keys[0] = "counter";
        keys[1] = "counter2";
        _initStorage(myStorage, keys);

        assertTrue(_isStorageInUse(myStorage));
        assertEq(_readStorageUintKey(myStorage, "counter"), 0);
        assertEq(_readStorageUintKey(myStorage, "counter2"), 0);

        _saveStorageUintKey(myStorage, "counter", 111);
        assertEq(_readStorageUintKey(myStorage, "counter"), 111);
        assertEq(_readStorageUintKey(myStorage, "counter2"), 0);

        _incrementStorageUintKey(myStorage, "counter");
        assertEq(_readStorageUintKey(myStorage, "counter"), 112);
        assertEq(_readStorageUintKey(myStorage, "counter2"), 0);

        _removeStorage(myStorage);
        assertFalse(_isStorageInUse(myStorage));
    }
}
