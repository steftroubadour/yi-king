// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

interface IYiJingBase {
    struct Hexagram {
        uint8[6] lines;
    }

    struct NftData {
        Hexagram hexagram;
        uint64 date; // Epoch time
        bool encrypted;
        string info;
        string encryptionHelperMessage;
    }

    struct NftDataExtended {
        uint256 tokenId;
        Hexagram hexagram;
        uint64 date;
        bool encrypted;
        string info;
        string encryptionHelperMessage;
    }
}
