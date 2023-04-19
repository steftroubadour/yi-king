// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IYiJingMetadataGenerator, IYiJingBase } from "src/interface/IYiJingMetadataGenerator.sol";
import { Pausable } from "src/utils/Pausable.sol";
import { WithAffiliation, IAffiliation } from "src/WithAffiliation.sol";

/// @author Stephane Chaunard <linktr.ee/stephanechaunard>
/// @title Affiliation contract
contract YiJingNft is ERC721, IYiJingBase, Pausable, WithAffiliation {
    /*////////////////////////////////////////////////////
                      REVERT REASONS
    ////////////////////////////////////////////////////*/
    string constant REVERT_PAYMENT = "NFT: value too small";
    string constant REVERT_NOT_APPROVED = "NFT: not owner or approved";
    string constant REVERT_ENCRYPTED = "NFT: encrypted info";
    string constant REVERT_NOT_ENCRYPTED = "NFT: not encrypted info";

    IYiJingMetadataGenerator _metadataGenerator;

    mapping(uint256 => NftData) private _nftData;
    uint256 private _lastTokenId;
    uint256 public mintPrice;

    /*////////////////////////////////////////////////////
                        MODIFIERS
    ////////////////////////////////////////////////////*/
    modifier validatePayment() {
        require(msg.value >= mintPrice, REVERT_PAYMENT);
        _;
    }

    modifier notEncrypted(uint256 tokenId) {
        require(!_nftData[tokenId].encrypted, REVERT_ENCRYPTED);
        _;
    }

    modifier encrypted(uint256 tokenId) {
        require(!_nftData[tokenId].encrypted, REVERT_NOT_ENCRYPTED);
        _;
    }

    constructor(
        address imagesGenerator,
        address affiliation
    ) ERC721("Yi Jing Saver", "YIJING") WithAffiliation(affiliation) {
        _metadataGenerator = IYiJingMetadataGenerator(imagesGenerator);
        setMintPrice(1 ether);
    }

    /*////////////////////////////////////////////////////
                      EXTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/

    /// Mint
    /// @param nftData nft data
    function mint(
        NftData memory nftData,
        address affiliate
    ) external payable whenNotPaused validatePayment {
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

    // Transfer
    // Authorize owner to re-encrypt information before transfer
    // For example, it can be useful, even if it is not recommended, if it is encrypted with private key account owner.
    // In this case, it is recommended to use an account private key one time
    // i.e. use a wallet derivation one time.
    // This derivation and main address (derivation 0) could be store in
    // ONE TIME because with encrypted messageS from one account, it is possible to calculate private key of this account.
    // It is why, normally, only signature hash is stored, NOT encrypted message.
    /// @dev See {IERC721-transferFrom}.
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override notEncrypted(tokenId) {
        super.transferFrom(from, to, tokenId);
    }

    function transferFromEncrypted(
        address from,
        address to,
        uint256 tokenId,
        string memory encryptedInfo,
        string memory encryptionHelperMessage
    ) public encrypted(tokenId) {
        _modifyEncryptedInfo(tokenId, encryptedInfo, encryptionHelperMessage);
        super.transferFrom(from, to, tokenId);
    }

    /// @dev See {IERC721-safeTransferFrom}.
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override notEncrypted(tokenId) {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFromEncrypted(
        address from,
        address to,
        uint256 tokenId,
        string memory encryptedInfo,
        string memory encryptionHelperMessage
    ) public encrypted(tokenId) {
        safeTransferFromEncrypted(from, to, tokenId, encryptedInfo, encryptionHelperMessage, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override notEncrypted(tokenId) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFromEncrypted(
        address from,
        address to,
        uint256 tokenId,
        string memory encryptedInfo,
        string memory encryptionHelperMessage,
        bytes memory data
    ) public encrypted(tokenId) {
        _modifyEncryptedInfo(tokenId, encryptedInfo, encryptionHelperMessage);
        super.safeTransferFrom(from, to, tokenId, data);
    }

    /// Retrieve on-the-same-chain Token Metadata
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId); // To exclude burned tokens
        return
            _metadataGenerator.getJsonMetadata(
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

    function withdraw() external onlyOwner {
        uint256 affiliatesBalance = IAffiliation(getAffiliation()).getTotalBalance();
        payable(_msgSender()).transfer(address(this).balance - affiliatesBalance);
    }

    function affiliateWithdraw() external {
        uint256 balance = IAffiliation(getAffiliation()).withdraw(_msgSender());
        payable(_msgSender()).transfer(balance);
    }

    /*////////////////////////////////////////////////////
                      INTERNALS FUNCTIONS
    ////////////////////////////////////////////////////*/

    function _modifyEncryptedInfo(
        uint256 tokenId,
        string memory info,
        string memory helperMessage
    ) internal {
        _nftData[tokenId].info = info;
        _nftData[tokenId].encryptionHelperMessage = helperMessage;
    }
}
