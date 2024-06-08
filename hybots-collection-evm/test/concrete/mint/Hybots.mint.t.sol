// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { IERC1155Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

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
        nft.mint(alice, 1, 1, "");
    }

    function test_WhenMinterTryToMintToAddressZero() external {
        vm.startPrank(chuck);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(0)));
        nft.mint(address(0), 1, 1, "");
    }

    function test_WhenMinterMintedNftToUser() external {
        uint256 userBalanceBefore = nft.balanceOf(alice, 1);
        vm.startPrank(chuck);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit Hybots.Minted(alice, 1, 1, "");

        nft.mint(alice, 1, 1, "");

        // it user balance increased
        assertEq(userBalanceBefore + 1, nft.balanceOf(alice, 1));
    }
}
