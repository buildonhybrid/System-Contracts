// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/*
 * @title Hybots NFT collection.
 * @author Cowchain
 * @notice Implementation of the NFT collection using ERC1155 standart with
 * metadata uri for every tokenId, burning by user and minting tokens by
 * Minter role for allow bridge tokens between different chains.
 */
contract Hybots is
    ERC721,
    ERC721Enumerable,
    AccessControl,
    ERC721URIStorage,
    ERC721Burnable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 private _nextTokenId;

    string public baseUri;

    /// @notice Mapping of allowed rarities.
    mapping(string => bool) isAllowedRarity;

    /// @notice Mapping of rarities.
    mapping(uint256 => string) public rarities;

    /// @notice Emits when single nft was minted to user.
    event Minted(address to, uint256 tokenId);

    /// @notice Emits when base uri to metadata is updated.
    event BaseURIUpdated(string newUri);

    error UnaceptableValue();

    /// @param defaultAdmin Address which will be has permissions to execute main functions like set Uri or grant/revoke roles.
    /// @param minter Address which will be able to mint new tokens.
    /// @param baseUri_ Base uri to metadata storage for whole collection.
    constructor(
        address defaultAdmin,
        address minter,
        string memory baseUri_
    ) ERC721("HybotsCollection", "HYB") {
        if (defaultAdmin == address(0) || minter == address(0)) {
            revert UnaceptableValue();
        }

        baseUri = baseUri_;

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);

        emit BaseURIUpdated(baseUri_);
    }

    /// @notice Updates the baseURI.
    /// @param baseURI_ New value for baseURI.
    function updateBaseURI(
        string memory baseURI_
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        baseUri = baseURI_;

        emit BaseURIUpdated(baseURI_);
    }

    /// @notice Returns the base uri for collection.
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }

    /// @inheritdoc ERC721
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return string.concat(super.tokenURI(tokenId), ".json");
    }

    /// @notice Mint new nft to certain user.
    /// @param to User which will get new minted nft.
    function mint(address to, string calldata rarity) public onlyRole(MINTER_ROLE) {
        if (!isAllowedRarity[rarity]) {
            revert UnaceptableValue();
        }

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);

        rarities[tokenId] = rarity;

        emit Minted(to, tokenId);
    }

    /// @notice Add new rarity to collection.
    function addRarity(string memory rarity) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isAllowedRarity[rarity] = true;
    }

    /// @notice Remove rarity from collection.
    function removeRarity(string memory rarity) public onlyRole(DEFAULT_ADMIN_ROLE) {
        isAllowedRarity[rarity] = false;
    }

    /// @dev The following functions are overrides required by Solidity.
    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, AccessControl, ERC721URIStorage, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
