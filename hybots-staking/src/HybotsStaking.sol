// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/*
* @title HybotsStaking
* @author Cowchain
* @description This protocol was created for staking Hybots NFTs and track staked tokens by owner. 
*/
contract HybotsStaking is Ownable, IERC721Receiver {
    using EnumerableSet for EnumerableSet.UintSet;

    using SafeERC20 for IERC20;

    /// @notice address of Hybots nft collection.
    IERC721 public hybotsCollection;

    /// @notice number of total locked hybots nfts.
    uint32 public numberOfLockedTokens;

    /// @notice is users able to unstake their nfts or no.
    bool public isUnstakeAvailable;

    /// @notice collection of tokenIds staked by users.
    mapping(uint256 tokenId => address owner) public nftOwnerByTokenId;

    /// @notice collection of nfts staked by user.
    mapping(address owner => EnumerableSet.UintSet ids) internal stakedTokensByOwner;

    /// @notice emits when user staken nft.
    /// @param owner address of user which staked nft.
    /// @param tokenId id of the staked nft.
    event Staked(address owner, uint256 tokenId);

    /// @notice emits when user unstake his nft.
    /// @param owner address of user which staked nft.
    /// @param tokenId id of the staked nft.
    event Unstaked(address owner, uint256 tokenId);

    /// @notice emits when owner withdrawn native coin from contract. 
    /// @param to address of the eth receiver, it is always `owner`. 
    /// @param amount amount of withdraw eth in wei.
    event ETHWithdrawn(address to, uint256 amount);

    /// @notice emits when owner erc20 tokens from contract. 
    /// @param token address of the erc20 token which was withdrawn.
    /// @param to address of the eth receiver, it is always `owner`. 
    /// @param amount amount of withdraw token in wei.
    event TokenWithdrawn(IERC20 token, address to, uint256 amount);

    error UnaceptableValue();

    error UnstakeIsNotPossibleAtThatMoment();

    error NotOwnerOfStakedToken(uint256 tokenId);

    /// @param hybotsCollection_ address of the hybots nft collection.
    /// @param initialOwner address of the contractOwner.
    constructor(IERC721 hybotsCollection_, address initialOwner) Ownable(initialOwner) {
        if (address(hybotsCollection_) == address(0)) revert UnaceptableValue();

        hybotsCollection = hybotsCollection_;

        isUnstakeAvailable = false;
    }

    /// @notice main function for stake nft by user. 
    /// @param tokenId id of the nft which will be staked.
    function stake(uint256 tokenId) external {
        address sender = _msgSender();

        hybotsCollection.safeTransferFrom(sender, address(this), tokenId);

        ++numberOfLockedTokens;

        nftOwnerByTokenId[tokenId] = sender;

        stakedTokensByOwner[sender].add(tokenId);

        emit Staked(sender, tokenId);
    }

    /// @notice function for unstake nft by user. 
    /// @param tokenId id of the nft which will be unstaked.
    /// @dev possible only if `isUnstakeAvailable` equals true.
    function unstake(uint256 tokenId) external {
        address sender = _msgSender();

        if (nftOwnerByTokenId[tokenId] != sender) revert NotOwnerOfStakedToken(tokenId);

        if(isUnstakeAvailable != true) revert UnstakeIsNotPossibleAtThatMoment();

        hybotsCollection.safeTransferFrom(address(this), sender, tokenId);

        --numberOfLockedTokens;

        nftOwnerByTokenId[tokenId] = address(0);

        stakedTokensByOwner[sender].remove(tokenId);

        emit Unstaked(sender, tokenId);
    }

    /// @notice owner can enable unstaking for all users.
    function allowUnstake() external onlyOwner {
        isUnstakeAvailable = true;
    }

    /// @notice withdraw native coin and transfer it to owner.
    function withdrawETH() external onlyOwner {
        uint256 amount = address(this).balance;
        payable(_msgSender()).transfer(amount);

        emit ETHWithdrawn(_msgSender(), amount);
    }

    /// @notice withdraw tokens and transfer it to owner.
    /// @param token address of the token which will be withdrawn. 
    /// @param amount amount of token which will be withdrawn in wei. 
    function withdrawToken(IERC20 token, uint256 amount) external onlyOwner {
        if (address(token) == address(0)) revert UnaceptableValue();

        token.safeTransfer(_msgSender(), amount);

        emit TokenWithdrawn(token, _msgSender(), amount);
    }

    /// @notice returns all ids of staked nfts by given user.
    function getAllStakedTokensByOwner(address owner_) public view returns (uint256[] memory ids) {
        ids = stakedTokensByOwner[owner_].values();
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
