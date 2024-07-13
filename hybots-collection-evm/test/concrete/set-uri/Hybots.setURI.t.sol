// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { HybotsTest } from "test/HybotsTest.sol";
import { Hybots } from "src/Hybots.sol";

contract HybotssetURI is HybotsTest {
    function setUp() external {
        fixture();

        vm.prank(chuck);
        nft.mint(chuck);
    }

    function test_WhenCallerIsNotAdmin() external {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, alice, nft.DEFAULT_ADMIN_ROLE()
            )
        );
        nft.updateBaseURI("example.com/test/");
    }

    function test_WhenCallerIsAdmin() external {
        vm.startPrank(carol);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit Hybots.BaseURIUpdated("example.com/test/");

        nft.updateBaseURI("example.com/test/");

        // it uri is updated
        assertEq(nft.tokenURI(0), "example.com/test/0.json");
    }
}
