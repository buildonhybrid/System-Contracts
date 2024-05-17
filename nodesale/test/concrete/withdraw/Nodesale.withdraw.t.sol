// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { NodesaleTest } from "test/NodesaleTest.sol";
import { INodesale } from "src/INodesale.sol";

contract Nodesalewithdraw is NodesaleTest {
    function setUp() external {
        fixture();

        vm.prank(alice);
        nodesale.buy(5, 5, emptyRefferalCode);
    }

    function test_WhenNotOwnerTryToWithdrawTokens() external {
        vm.prank(alice);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        nodesale.withdraw(alice);
    }

    function test_WhenRecipientEqualsAddressZero() external {
        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);
        nodesale.withdraw(address(0));
    }

    function test_WhenOwnerWithdrawTokens() external {
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));
        uint256 recipientBalanceBefore = weth.balanceOf(alice);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Withdrawn(alice, contractBalanceBefore);

        nodesale.withdraw(alice);

        // it contract balance is reduced to zero
        assertEq(weth.balanceOf(address(nodesale)), 0);

        // it recipient balance is increased by collected tokens
        assertEq(recipientBalanceBefore + contractBalanceBefore, weth.balanceOf(alice));
    }
}
