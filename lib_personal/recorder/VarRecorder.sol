// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { Test } from "forge-std/Test.sol";
import { RandomHelper } from "../helper/RandomHelper.sol";

// Use to record data between tests, to pass data to another test
abstract contract VarRecorder is RandomHelper {
    string[] internal testStorages;
    string[] internal fuzzStorages;
    string[] internal helpStorages;

    function _initialiseStorages() internal {
        for (uint256 i; i < 10; i++) {
            testStorages.push(vm.toString(_getRandomNumber(10 ** 18, 10 ** 19 - 1)));
        }

        for (uint256 j; j < 10; j++) {
            fuzzStorages.push(vm.toString(_getRandomNumber(10 ** 17, 10 ** 18 - 1)));
        }

        for (uint256 j; j < 10; j++) {
            helpStorages.push(vm.toString(_getRandomNumber(10 ** 16, 10 ** 17 - 1)));
        }
    }

    function _getVarPath(string memory name) internal pure returns (string memory) {
        return string.concat("./records/", name, ".txt");
    }

    function _closeVar(string memory name) internal {
        vm.closeFile(_getVarPath(name));
    }

    function _removeVar(string memory name) internal {
        vm.removeFile(_getVarPath(name));
    }

    function _isVarExist(string memory name) internal view returns (bool) {
        bool isVarExist;
        try vm.readFile(_getVarPath(name)) {
            isVarExist = true;
        } catch {}

        return isVarExist;
    }

    function _readUintVar(string memory name) internal returns (uint256) {
        string memory path = _getVarPath(name);
        vm.closeFile(path);

        return vm.parseUint(vm.readLine(path));
    }

    function _incrementUintVar(string memory name) internal {
        uint256 value = _readUintVar(name);

        vm.writeFile(_getVarPath(name), vm.toString(++value));
    }

    function _initializeUintVar(string memory name, uint256 value) internal {
        vm.writeFile(_getVarPath(name), vm.toString(value));
    }

    function _getStoragePath(string memory name) internal pure returns (string memory) {
        return string.concat("./records/", name, ".json");
    }

    function _closeStorage(string memory name) internal {
        vm.closeFile(_getStoragePath(name));
    }

    function _removeStorage(string memory name) internal {
        vm.removeFile(_getStoragePath(name));
    }

    function _isStorageInUse(string memory name) internal view returns (bool) {
        bool isStorageInUse;

        try vm.readFile(_getStoragePath(name)) {
            isStorageInUse = true;
        } catch {}

        return isStorageInUse;
    }

    function _initStorage(string memory name) internal {
        string memory path = _getStoragePath(name);
        if (_isStorageInUse(name)) return;

        vm.writeJson("{}", path);
    }

    function _initStorage(string memory name, string[] memory keys) internal {
        string memory path = _getStoragePath(name);

        if (_isStorageInUse(name)) return;

        string memory jsonObj = "json";
        string memory finalJson;
        for (uint256 i; i < keys.length; i++) {
            finalJson = vm.serializeUint(jsonObj, keys[i], 0);
        }
        vm.writeJson(finalJson, path);
    }

    function _readStorageUintKey(string memory name, string memory key) internal returns (uint256) {
        string memory path = _getStoragePath(name);
        vm.closeFile(path);
        string memory jsonFile = vm.readFile(path);

        return vm.parseJsonUint(jsonFile, string.concat(".", key));
    }

    function _saveStorageUintKey(string memory name, string memory key, uint256 value) internal {
        string memory path = _getStoragePath(name);

        if (!_isStorageInUse(name)) return;

        vm.writeJson(vm.toString(value), path, string.concat(".", key));
    }

    function _incrementStorageUintKey(string memory name, string memory key) internal {
        string memory path = _getStoragePath(name);
        uint256 value = _readStorageUintKey(name, key);
        vm.closeFile(path);
        _saveStorageUintKey(name, key, ++value);
    }
}
