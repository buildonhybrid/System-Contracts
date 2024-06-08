// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Test as ForgeTest } from "forge-std/Test.sol";

contract Test is ForgeTest {
    uint256 internal constant privateKey = 12345;

    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");
    address internal chuck = makeAddr("chuck");
    address internal manager = vm.addr(privateKey);
    address internal deployer = makeAddr("deployer");

    address[] internal actors = [deployer, alice, bob, carol, chuck];
}
