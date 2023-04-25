// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IYiJingMetadataGenerator, IYiJingBase } from "src/interface/IYiJingMetadataGenerator.sol";
import { Pausable } from "src/utils/Pausable.sol";
import { WithAffiliation, IAffiliation } from "src/WithAffiliation.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title Yi Jing Saver NFT Collection based on erc721 contract
// Generalities for these NFT tokens as storage utilities which price can't be speculative.
// Due to high gas price on Ethereum and usage of lower gas solutions like StarkWare,
// It's better to mint again an NFT than modify or transfer it.
//
// To avoid evolution problem, it would be better to choose a Diamond architecture
// But in our case, we assume that interfaces are efficients,
// they propose all methods we need and they won't need to evolve,
// Even if we can upgrade some 'satellites' contracts, their interfaces can be fixed.
// Upgradable dependant contracts are Affiliation, YiJingMetadataGenerator and YiJingImagesGenerator
//
contract YiJingNft is ERC721, IYiJingBase, Pausable, WithAffiliation {
    /*////////////////////////////////////////////////////
                      REVERT REASONS
    ////////////////////////////////////////////////////*/
    string constant REVERT_PAYMENT = "NFT: value too small";
    string constant REVERT_NOT_APPROVED = "NFT: not owner or approved";
    string constant REVERT_NOT_OWNER_OF = "NFT: not owner of";

    address public metadataGenerator;

    mapping(uint256 => NftData) private _nftData;
    uint256 private _lastTokenId;
    uint256 public mintPrice;

    constructor(
        address metadataGenerator_,
        address affiliation_
    ) ERC721("Yi Jing Saver", "YIJING") WithAffiliation(affiliation_) {
        metadataGenerator = metadataGenerator_;
        setMintPrice(0.001 ether);
    }

    /*////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/

    /// Mint
    /// @param nftData nft data
    function mint(NftData memory nftData, address affiliate) external payable whenNotPaused {
        require(msg.value >= mintPrice, REVERT_PAYMENT);
        _lastTokenId++;
        _nftData[_lastTokenId] = nftData;
        _addAffiliateCommission(affiliate, msg.value);
        _safeMint(_msgSender(), _lastTokenId);
    }

    /// Burn
    /// @param tokenId token id
    function burn(uint256 tokenId) external whenNotPaused {
        require(_isApprovedOrOwner(_msgSender(), tokenId), REVERT_NOT_APPROVED);
        _burn(tokenId);
    }

    // Modify encrypted info
    // Authorize owner to re-encrypt NFT information
    // use cases:
    // - to improve encryption with a better encryption method.
    // - before or after a transfer
    //
    // For example, it can be useful, even if it is not recommended, if it is encrypted with private key account owner.
    // In this case, it is recommended to use an account private key one time
    // i.e. use a wallet derivation one time.
    // This derivation and main address (derivation 0) could be store in
    // ONE TIME because with encrypted messageS from one account, it is possible to calculate private key of this account.
    // It is why, normally, only signature hash is stored, NOT encrypted message.
    //
    function modifyEncryptedInfo(
        uint256 tokenId,
        string memory info,
        string memory helperMessage
    ) public {
        require(ownerOf(tokenId) == _msgSender(), REVERT_NOT_OWNER_OF);
        _nftData[tokenId].info = info;
        _nftData[tokenId].encryptionHelperMessage = helperMessage;
    }

    /// Retrieve on-the-same-chain Token Metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId); // To exclude burned tokens
        return
            IYiJingMetadataGenerator(metadataGenerator).getJsonMetadata(
                NftDataExtended(
                    tokenId,
                    _nftData[tokenId].hexagram,
                    _nftData[tokenId].date,
                    _nftData[tokenId].encrypted,
                    _nftData[tokenId].info,
                    _nftData[tokenId].encryptionHelperMessage
                )
            );
    }

    function setMintPrice(uint256 price) public onlyOwner {
        mintPrice = price;
    }

    function setMetadataGenerator(address metadataGenerator_) public onlyOwner {
        metadataGenerator = metadataGenerator_;
    }

    function setAffiliation(address affiliation) public onlyOwner {
        _setAffiliation(affiliation);
    }

    function withdraw() external onlyOwner {
        uint256 affiliatesBalance = IAffiliation(getAffiliation()).getTotalBalance();
        payable(_msgSender()).transfer(address(this).balance - affiliatesBalance);
    }

    function affiliateWithdraw() external {
        uint256 balance = IAffiliation(getAffiliation()).withdraw(_msgSender());
        payable(_msgSender()).transfer(balance);
    }
}
