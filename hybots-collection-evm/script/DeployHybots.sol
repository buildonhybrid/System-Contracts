// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Script, console } from "forge-std/Script.sol";

import { Hybots } from "src/Hybots.sol";

contract DeployHybots is Script {
    string public baseUri = "";

    function run() public {
        vm.startBroadcast();

        Hybots nft = new Hybots(msg.sender, msg.sender, baseUri);

        console.log("Contract deployed successfully at address: ", address(nft));

        vm.stopBroadcast();
    }
}
