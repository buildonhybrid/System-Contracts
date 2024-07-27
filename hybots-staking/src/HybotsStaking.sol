// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract HybotsStaking is Ownable, IERC721Receiver {
    using EnumerableSet for EnumerableSet.UintSet;

    IERC721 public hybotsCollection;

    uint32 public numberOfLockedTokens;

    mapping(uint256 tokenId => address owner) public nftOwnersByTokenId;

    mapping(address owner => EnumerableSet.UintSet ids) internal stakedTokensByOwner;

    event Staked(address owner, uint256 tokenId);

    error UnaceptableValue();

    constructor(IERC721 hybotsCollection_, address initialOwner) Ownable(initialOwner) {
        if (address(hybotsCollection_) == address(0)) revert UnaceptableValue();

        hybotsCollection = hybotsCollection_;
    }

    function stake(uint256 tokenId) external {
        address sender = _msgSender();

        hybotsCollection.safeTransferFrom(sender, address(this), tokenId);

        ++numberOfLockedTokens;

        nftOwnersByTokenId[tokenId] = sender;

        stakedTokensByOwner[sender].add(tokenId);

        emit Staked(sender, tokenId);
    }

    function getAllStakedTokensByOwner(address owner_) public view returns (uint256[] memory ids) {
        ids = stakedTokensByOwner[owner_].values();
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
