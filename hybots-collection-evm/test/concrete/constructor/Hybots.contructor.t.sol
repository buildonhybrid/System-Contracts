// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { HybotsTest } from "test/HybotsTest.sol";
import { Hybots } from "src/Hybots.sol";

contract Hybotscontructor is HybotsTest {
    function test_WhenDefaultAdminEqualsAddressZero() external {
        // it revert
        vm.expectRevert(Hybots.UnaceptableValue.selector);

        new Hybots(address(0), bob, "example.com/{id}");
    }

    function test_WhenMinterEqualsAddressZero() external {
        // it revert
        vm.expectRevert(Hybots.UnaceptableValue.selector);

        new Hybots(bob, address(0), "example.com/{id}");
    }

    function test_WhenEverythingIsCorrect() external {
        nft = new Hybots(bob, alice, "example.com/");

        // it roles are set
        assertEq(nft.hasRole(0x00, bob), true);
        assertEq(nft.hasRole(nft.MINTER_ROLE(), alice), true);

        // it state is updated
        assertEq(nft.uri(1), "example.com/1.json");
    }
}
