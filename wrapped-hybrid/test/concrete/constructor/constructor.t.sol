// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { WrappedHybridTest } from "test/WrappedHybridTest.sol";
import { WrappedHybrid } from "src/WrappedHybrid.sol";

contract constructoroTest is WrappedHybridTest {
    function test_WhenInitialOwnerIsAddressZero() external {
        // it reverts
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        new WrappedHybrid(address(0));
    }

    function test_WhenInitialOwnerIsCorrect() external {
        // it emits
        vm.expectEmit(true, true, false, false);
        emit Ownable.OwnershipTransferred(address(0), chuck);

        WrappedHybrid wrappedHybrid = new WrappedHybrid(chuck);

        // it owner is updated
        assertEq(wrappedHybrid.owner(), chuck);
    }
}
