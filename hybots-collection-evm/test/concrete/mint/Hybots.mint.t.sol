// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { IERC721Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import { HybotsTest } from "test/HybotsTest.sol";
import { Hybots } from "src/Hybots.sol";

contract HybotsMint is HybotsTest {
    function setUp() external {
        fixture();
    }

    function test_WhenNotMinterTryToMint() external {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, alice, nft.MINTER_ROLE())
        );
        nft.mint(alice, Hybots.Rarity.gold);
    }

    function test_WhenMinterTryToMintToAddressZero() external {
        vm.startPrank(chuck);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721InvalidReceiver.selector, address(0)));
        nft.mint(address(0), Hybots.Rarity.silver);
    }

    function test_WhenMinterMintedNftToUser() external {
        uint256 userBalanceBefore = nft.balanceOf(alice);
        vm.startPrank(chuck);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit Hybots.Minted(alice, 0);

        nft.mint(alice, Hybots.Rarity.bronze);

        // it user balance increased
        assertEq(userBalanceBefore + 1, nft.balanceOf(alice));
    }
}
