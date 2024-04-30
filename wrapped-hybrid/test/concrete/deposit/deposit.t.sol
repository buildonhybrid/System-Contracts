// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { WrappedHybridTest } from "test/WrappedHybridTest.sol";
import { IWrappedHybrid } from "src/IWrappedHybrid.sol";

contract depositTest is WrappedHybridTest {
    function setUp() public {
        fixture();
    }

    function test_WhenUserSend0WeiToFunction() external {
        uint256 userTokenBalanceBefore = wrappedHybrid.balanceOf(alice);
        uint256 userBalanceBefore = alice.balance;
        uint256 contractBalanceBefore = address(wrappedHybrid).balance;

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(false, false, false, true);

        emit IWrappedHybrid.Deposited(alice, 0 ether);

        wrappedHybrid.deposit{ value: 0 }();

        // it wrapped balance of user will be not changed.

        assertEq(userTokenBalanceBefore, wrappedHybrid.balanceOf(alice));

        assertEq(userBalanceBefore, alice.balance);

        assertEq(contractBalanceBefore, address(wrappedHybrid).balance);
    }

    function test_WhenUserCallDepositFunctionWithEther() external {
        uint256 userTokenBalanceBefore = wrappedHybrid.balanceOf(alice);
        uint256 userBalanceBefore = alice.balance;
        uint256 contractBalanceBefore = address(wrappedHybrid).balance;

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(false, false, false, true);

        emit IWrappedHybrid.Deposited(alice, 1 ether);

        wrappedHybrid.deposit{ value: 1 ether }();

        // it new wrapped tokens minted
        assertEq(userTokenBalanceBefore, wrappedHybrid.balanceOf(alice) - 1 ether);

        // it user ether balance reduced
        assertEq(userBalanceBefore - 1 ether, alice.balance);

        // it contract ether balance increased
        assertEq(contractBalanceBefore + 1 ether, address(wrappedHybrid).balance);
    }
}
