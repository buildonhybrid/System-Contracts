// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/*
 * @title Nybots NFT collection.
 * @author Cowchain
 * @notice Implementation of the NFT collection using ERC1155 standart with
 * metadata uri for every tokenId, burning by user and minting tokens by
 * Minter role for allow bridge tokens between different chains.
 */
contract Hybots is ERC1155, AccessControl, ERC1155Burnable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @param defaultAdmin Address which will be has permissions to execute main functions like set Uri or grant/revoke roles.
    /// @param minter Address which will be able to mint new tokens.
    /// @param baseUri Base uri to metadata storage for whole collection.
    constructor(
        address defaultAdmin,
        address minter,
        string memory baseUri
    ) ERC1155(baseUri) {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    /// @notice Updates based uri to metadata storage.
    /// @dev Can be executed only by admin.
    /// @param newUri New uri to metadata storage.
    function setURI(string memory newUri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newUri);
    }

    /// @notice Mint new nft to certain user with selected id and amount.
    /// @param to User which will get new minted nft.
    /// @param id Id of the nft type which will be minted.
    /// @param amount Amount of nfts which will be minted.
    /// @param data Bytes with which nft will be minted.
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mint(to, id, amount, data);
    }

    /// @notice Mint a batch of new nfts to certain user with selected id and amount.
    /// @param to User which will get new minted nft.
    /// @param ids Collection of the ids which represent types of nft.
    /// @param amounts Collection of amounts which will be minted to user.
    /// @param data Bytes with which nft will be minted.
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, data);
    }

    /// @notice Returns uri to metadata for given tokenId.
    /// @param tokenId Id of the token for get uri.
    function uri(uint256 tokenId) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    super.uri(tokenId),
                    Strings.toString(tokenId),
                    ".json"
                )
            );
    }

    /// @dev The following function is overrides required by Solidity.
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
