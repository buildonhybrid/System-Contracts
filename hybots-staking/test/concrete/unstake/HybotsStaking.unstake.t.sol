// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IERC721Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import { HybotsStaking } from "src/HybotsStaking.sol";
import { HybotsStakingTest } from "test/HybotsStakingTest.sol";

contract HybotsStakingUnstake is HybotsStakingTest {
    function setUp() public {
        fixture();

        vm.prank(alice);
        staking.stake(1);
    }

    function test_WhenNotTokenOwnerTriesToUnstakeIt() external {
        vm.startPrank(bob);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(HybotsStaking.NotOwnerOfStakedToken.selector, 1));
        staking.unstake(1);
    }

    function test_WhenUserUnstakedHisToken() external {
        uint256 lockedTokensBefore = staking.numberOfLockedTokens();

        assertEq(staking.getAllStakedTokensByOwner(alice).length, 1);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit HybotsStaking.Unstaked(alice, 1);

        vm.prank(alice);
        staking.unstake(1);

        // it owner of nft is equals user address
        assertEq(alice, nft.ownerOf(1));

        // it staker of given nft equals zero after unstake
        assertEq(staking.nftOwnerByTokenId(1), address(0));

        // it tokenId removed from list of staked tokens by user
        assertEq(staking.getAllStakedTokensByOwner(alice).length, 0);

        // it number of staked tokens reduced
        assertEq(lockedTokensBefore - 1, staking.numberOfLockedTokens());
    }
}
