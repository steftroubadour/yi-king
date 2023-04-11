// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "../helper/Helpers.sol";

// Use to record data during the same test
abstract contract FuzzRecorder is Test, Helpers {
    bool internal record;
    bool internal displayRecords;

    /*struct Log {
        bytes32[] topics;
        bytes data;
        address emitter;
    }*/
    Vm.Log[] internal _logs;

    // todo voir si on peut enregistrer les logs dans un fichier, lors d'un test random
    // tests random en suivant un workflow au niveau des SaleStatus,  Array ?
    // print les infos dans un fichier

    // Store logs in memory
    function _storeLogs() internal {
        Vm.Log[] memory logs;
        logs = vm.getRecordedLogs();

        for (uint256 i; i < logs.length; i++) {
            _logs.push(logs[i]);
        }
    }

    // Serialize logs
    function _serializeLogs() internal returns (string memory) {
        /*struct Log {
            bytes32[] topics;
            bytes data;
            address emitter;
        }*/

        string memory finalJson = "[";
        for (uint256 i; i < _logs.length; i++) {
            Vm.Log memory log = _logs[i];
            // write a log
            // Serialize log
            string memory obj1 = "log object";
            vm.serializeBytes32(obj1, "topics", log.topics);
            vm.serializeBytes(obj1, "data", log.data);
            string memory logJson = vm.serializeAddress(obj1, "emitter", log.emitter);
            finalJson = string.concat(finalJson, logJson);

            if (i < _logs.length - 1) {
                finalJson = string.concat(finalJson, ", ");
            }
        }

        return string.concat(finalJson, "]");
    }

    function _printLogs() internal {
        // ...
    }

    // Save logs in a file
    function _saveLogs() internal {
        // logs must be stored before : _storeLogs();
        vm.writeJson(_serializeLogs(), "./output/records.json");
    }

    function _writeNewFile(string memory filename, string memory data) internal {
        vm.writeFile(string.concat("./records/", filename), data);
    }

    // Used to debug fuzz test
    // Erase debug.txt before
    //_writeNewLine("debug.txt", string.concat("tokenId: ", vm.toString(tokenId)));
    function _writeNewLine(string memory filename, string memory data) internal {
        vm.writeLine(string.concat("./records/", filename), data);
    }
}
