// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { DSTest } from "forge-std/Test.sol";

abstract contract GasHelper is DSTest {
    string private checkpointLabel;
    uint256 private checkpointGasLeft = 1; // Start the slot warm.
    uint256 private gasUsed;

    function startMeasuringGas(string memory label) internal virtual {
        checkpointLabel = label;
        checkpointGasLeft = gasleft();
    }

    function stopMeasuringGas() internal virtual {
        uint256 checkpointGasLeft2 = gasleft();

        // Subtract 100 to account for the warm SLOAD in startMeasuringGas.
        emit log_named_uint(
            string(abi.encodePacked(checkpointLabel, " Gas")),
            checkpointGasLeft - checkpointGasLeft2 - 100
        );
    }
}

/*////////////////////////////////////
            Usage example
//////////////////////////////////////

        function itInterfaceGasConsumption(bytes4 interfaceSign, string memory interfaceName) internal {
        // #supportsInterface() must use less than 30 000 gas.

        string memory key;
        uint256 value;
        Vm.Log[] memory entries;

        startMeasuringGas(string.concat("#supportsInterface(", interfaceName, ")"));
        assertTrue(nft.supportsInterface(interfaceSign));
        stopMeasuringGas();
        // Consume the recorded logs when called.
        entries = vm.getRecordedLogs();
        // struct Log { bytes32[] topics; bytes data; }
        assertEq(entries.length, 1);
        assertEq(entries[0].topics[0], keccak256("log_named_uint(string,uint256)"));
        assertEq(entries[0].topics.length, 1);
        (key, value) = abi.decode(entries[0].data, (string, uint256));
        assertLt(value, 30000);
    }

    function testSupported() public {
        vm.recordLogs();

        itInterfaceGasConsumption(type(IERC2981).interfaceId, "IERC2981");
        itInterfaceGasConsumption(type(IERC721).interfaceId, "IERC721");
        itInterfaceGasConsumption(type(IERC721Metadata).interfaceId, "IERC721Metadata");
        itInterfaceGasConsumption(type(IERC165).interfaceId, "IERC165");
    }

//////////////////////////////////*/
