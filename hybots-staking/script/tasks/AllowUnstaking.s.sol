// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";

import {HybotsStaking} from "src/HybotsStaking.sol";

contract AllowUnstaking is Script {
    function run() public {
        vm.startBroadcast();

        HybotsStaking staking = HybotsStaking(
            0x78a7e3371fa53D9291CbA333A3bF00BB45b475C5
        );

        staking.allowUnstake();

        vm.stopBroadcast();
    }
}
