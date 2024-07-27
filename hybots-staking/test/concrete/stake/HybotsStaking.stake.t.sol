// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {HybotsStaking} from "src/HybotsStaking.sol";
import {HybotsStakingTest} from "test/HybotsStakingTest.sol";

contract HybotsStakingstake is HybotsStakingTest {

    function setUp() public {
        fixture();
    }

    function test_WhenNotNftOwnerTryToLockNft() external {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721IncorrectOwner.selector, alice, uint256(2), bob));
        staking.stake(2);
    }

    function test_WhenNftIsLockedByOwner() external {
        uint256 lockedTokensBefore = staking.numberOfLockedTokens();

        // it emits
        vm.expectEmit(true, true, true,true);
        emit HybotsStaking.Staked(alice, 1);

        vm.prank(alice);
        staking.stake(1);

        // it owner of nft is contract
        assertEq(address(staking), nft.ownerOf(1));

        // it tokenId written to user in contract
        assertEq(staking.nftOwnersByTokenId(1), alice);
        staking.getAllStakedTokensByOwner(alice);

        // it number of locked tokens increased
        assertEq(lockedTokensBefore + 1, staking.numberOfLockedTokens());
    }
}