// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test } from "test/helpers/Test.sol";

import { WrappedHybrid } from "src/WrappedHybrid.sol";

contract WrappedHybridTest is Test {
    WrappedHybrid internal wrappedHybrid;

    address[] actors = [alice, bob, carol, chuck];

    function fixture() internal {
        wrappedHybrid = new WrappedHybrid(chuck);

        vm.deal(address(wrappedHybrid), 100 ether);

        for (uint256 i = 0; i < actors.length; i++) {
            vm.deal(actors[i], 100 ether);
        }

        for (uint256 i = 0; i < actors.length; i++) {
            vm.prank(chuck);
            wrappedHybrid.mint(actors[i], 100 ether);
        }
    }
}
