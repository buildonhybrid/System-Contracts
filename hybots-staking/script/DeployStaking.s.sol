// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Script, console} from "forge-std/Script.sol";

import {HybotsStaking} from "src/HybotsStaking.sol";

contract DeployStaking is Script {
    IERC721 hybotsCollection = IERC721(address(0)); // TODO: replace `address(0)` with collection address before deploy.
    function run() public {
        vm.startBroadcast();

        HybotsStaking staking = new HybotsStaking(hybotsCollection, msg.sender);

        console.log(
            "Contract deployed successfully at address: ",
            address(staking)
        );

        vm.stopBroadcast();
    }
}
