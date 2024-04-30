// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { WrappedHybridTest } from "test/WrappedHybridTest.sol";
import { IWrappedHybrid } from "src/IWrappedHybrid.sol";

contract withdrawoutline is WrappedHybridTest {
    function setUp() public {
        fixture();
    }

    function test_WhenUserTryToUnwrapAmountLargerThanHisBalance() external {
        vm.startPrank(alice);

        uint256 userBalance = wrappedHybrid.balanceOf(alice);

        // it reverts
        vm.expectRevert(abi.encodeWithSelector(IWrappedHybrid.InsufficientBalance.selector, alice, userBalance + 1));
        wrappedHybrid.withdraw(userBalance + 1);
    }

    function test_WhenUserCallWithdrawFunctionWithCorrectBalance() external {
        vm.startPrank(alice);

        uint256 userTokenBalanceBefore = wrappedHybrid.balanceOf(alice);
        uint256 userBalanceBefore = alice.balance;

        // it emits
        vm.expectEmit(false, false, false, true);
        emit IWrappedHybrid.Withdrawn(alice, 1 ether);

        wrappedHybrid.withdraw(1 ether);

        // it wrapped token balance of the user reduced
        assertEq(userTokenBalanceBefore - 1 ether, wrappedHybrid.balanceOf(alice));

        // it ether balance of the user increased
        assertEq(userBalanceBefore + 1 ether, alice.balance);
    }
}
