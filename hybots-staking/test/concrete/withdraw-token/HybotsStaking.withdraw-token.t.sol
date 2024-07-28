// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {HybotsStaking} from "src/HybotsStaking.sol";
import {HybotsStakingTest} from "test/HybotsStakingTest.sol";
import {ERC20Mock} from "test/mocks/ERC20Mock.sol";

contract HybotsStakingwithdraw_token is HybotsStakingTest {
    ERC20Mock public token;

    function setUp() public {
        fixture();

        vm.startPrank(deployer);
        token = new ERC20Mock();
        token.transfer(address(staking), 10000);
        vm.stopPrank();
    }

    function test_WhenNotOwnerTryToWithdrawToken() external {
        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                bob
            )
        );

        vm.prank(bob);
        staking.withdrawToken(token, 10000);
    }

    function test_WhenOwnerTryToWithdrawToken() external {
        uint256 contractBalanceBefore = token.balanceOf(address(staking));
        uint256 ownerBalanceBefore = token.balanceOf(deployer);

        // it emits
        vm.expectEmit(true, true, true,true);
        emit HybotsStaking.TokenWithdrawn(token, deployer, 10000);

        vm.prank(deployer);
        staking.withdrawToken(token, 10000);

        // it owner balance increased
        assertEq(ownerBalanceBefore + 10000, token.balanceOf(deployer));

        // it contract balance reduced
        assertEq(contractBalanceBefore - 10000, token.balanceOf(address(staking)));
    }
}
