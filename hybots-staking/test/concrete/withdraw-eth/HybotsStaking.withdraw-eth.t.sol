// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {HybotsStaking} from "src/HybotsStaking.sol";
import {HybotsStakingTest} from "test/HybotsStakingTest.sol";

contract HybotsStakingwithdraw_eth is HybotsStakingTest {
    function setUp() public {
        fixture();

        vm.deal(address(staking), 10000);
    }

    function test_WhenNotOwnerTryToWithdrawEth() external {
        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                bob
            )
        );

        vm.prank(bob);
        staking.withdrawETH();
    }

    function test_WhenOwnerTryToWithdrawEth() external {
        uint256 contractBalanceBefore = address(staking).balance;
        uint256 ownerBalanceBefore = deployer.balance;

        // it emits
        vm.expectEmit(true, true, true, true); 
        emit HybotsStaking.ETHWithdrawn(deployer, 10000);

        vm.prank(deployer);
        staking.withdrawETH();

        // it owner balance increased
        assertEq(ownerBalanceBefore + 10000, deployer.balance);

        // it contract balance reduced
        assertEq(contractBalanceBefore - 10000, address(staking).balance);
    }
}
