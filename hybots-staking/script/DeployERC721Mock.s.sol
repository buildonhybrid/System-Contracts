// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";

import {ERC721Mock} from "test/mocks/ERC721Mock.sol";

contract DeployERC721Mock is Script {
    function run() public {
        vm.startBroadcast();

        ERC721Mock nft = new ERC721Mock(msg.sender);

        for (uint i = 0; i < 10; i++) {
            nft.safeMint(msg.sender);
        }

        console.log(
            "Contract deployed successfully at address: ",
            address(nft)
        );

        vm.stopBroadcast();
    }
}
