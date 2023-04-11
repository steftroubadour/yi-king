// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import { FuzzRecorder } from "lib_personal/recorder/FuzzRecorder.sol";

// Use to record data during the same test
abstract contract FuzzRecorder is FuzzRecorder {
    uint256[] internal mintCounters;
    uint256[] internal burnedCounters;

    // Record token ids by Type and by User
    mapping(address => mapping(TokenType => uint256[])) public tokensStorage;
    mapping(address => UserAction[]) private usersActions;

    address[] public recordedUsers;
    mapping(address => bool) areAlreadyRecorded;

    mapping(uint256 => bool) isUsed;

    /*/////////////////////////////////////
            Write TYPES used in tests
        /////////////////////////////////////*/
    enum TokenType {
        Common,
        Special,
        Rare,
        Team
    }

    enum MintType {
        PresaleOne,
        PresaleTwo,
        PresaleThree,
        PublicSale,
        Exchange,
        OpenSale
    }

    struct UserAction {
        bytes4 selector;
        bytes data; // abi.encoded parameters,
        // https://solidity-fr.readthedocs.io/fr/latest/cheatsheet.html#global-variables
    }

    function _getMintCount() internal view returns (uint256) {
        uint256 minted;
        for (uint256 i; i < mintCounters.length; i++) {
            minted += mintCounters[i];
        }

        uint256 burned;
        for (uint256 i; i < burnedCounters.length; i++) {
            burned += burnedCounters[i];
        }

        require(minted >= burned);

        return minted - burned;
    }

    function _recordMintedToken(address user, uint256 tokenId) public {
        if (!record) return;

        tokensStorage[user][_getTokenType(tokenId)].push(tokenId);
        if (!areAlreadyRecorded[user]) recordedUsers.push(user);
    }

    function _recordRandomNumber(uint256 number, TokenType tokenType) public {
        if (!record) return;
        tokensStorage[address(0)][tokenType].push(number);
        //_writeNewLine("test.txt", string.concat("tokenId: ", vm.toString(number)));
    }

    function _verifyAllRecordedNumbers(uint256 min, uint256 max, TokenType tokenType) public {
        if (!record) return;

        assertEq(tokensStorage[address(0)][tokenType].length, max - min + 1);

        // Verify all numbers in the range are found only one time
        for (uint256 j; j < tokensStorage[address(0)][tokenType].length; j++) {
            uint256 number = tokensStorage[address(0)][tokenType][j];
            assertFalse(isUsed[number]);
            isUsed[number] = true;
        }
    }

    function _getTokenType(uint256 tokenId) internal view returns (TokenType) {
        if (_isTeamToken(tokenId)) return TokenType.Team;
        if (_isSpecialToken(tokenId)) return TokenType.Special;
        if (_isRareToken(tokenId)) return TokenType.Rare;
        return TokenType.Common;
    }

    function _getTokensIds(
        address owner,
        TokenType tokenType
    ) internal view returns (uint256[] memory) {
        return tokensStorage[owner][tokenType];
    }

    function _displayCommonTokensIds(
        uint256[] memory tokensIds
    ) internal view returns (string memory) {
        string memory text = "[";
        for (uint256 i; i < tokensIds.length; i++) {
            text = nft.isBurned(tokensIds[i])
                ? string.concat(text, "X", vm.toString(tokensIds[i]), "X")
                : string.concat(text, vm.toString(tokensIds[i]));
            if (i < tokensIds.length - 1) text = string.concat(text, ", ");
        }

        return string.concat(text, "]");
    }

    function _displayTokensIdsForUser(address user) internal {
        emit log(string.concat("-> user(", _removeUselessZeros(vm.toString(user)), ")"));
        emit log("---------------------------");
        uint256[] memory tokensIds = _getTokensIds(user, TokenType.Team);
        emit log(string.concat("TEAM ", vm.toString(tokensIds.length)));
        if (tokensIds.length > 0) emit log_array(tokensIds);
        tokensIds = _getTokensIds(user, TokenType.Special);
        emit log(string.concat("SPECIAL ", vm.toString(tokensIds.length)));
        if (tokensIds.length > 0) emit log_array(tokensIds);
        tokensIds = _getTokensIds(user, TokenType.Common);
        emit log(string.concat("COMMON ", vm.toString(tokensIds.length)));
        if (tokensIds.length > 0) emit log(_displayCommonTokensIds(tokensIds));
        tokensIds = _getTokensIds(user, TokenType.Rare);
        emit log(string.concat("RARE ", vm.toString(tokensIds.length)));
        if (tokensIds.length > 0) emit log_array(tokensIds);
        emit log("+++++++++++++++++++++++++++");
    }

    function _displayTokensIdsForUsersRange(address firstUser, uint256 quantity) internal {
        emit log("+++++++++++++++++++++++++++");
        emit log(
            string.concat(
                "Info for ",
                vm.toString(quantity),
                "th first users from:",
                _removeUselessZeros(vm.toString(firstUser))
            )
        );
        emit log("+++++++++++++++++++++++++++");

        for (uint256 i; i < quantity; i++) {
            _displayTokensIdsForUser(_userAddress(firstUser, i));
        }
    }
}
