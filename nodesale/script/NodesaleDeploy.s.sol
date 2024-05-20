// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Script } from "forge-std/Script.sol";

import { Nodesale } from "src/Nodesale.sol";
import { ERC20Sample } from "test/samples/ERC20Sample.sol";

contract NodesaleDeploy is Script {
    Nodesale public nodesale;

    uint256[] internal prices = [10, 20, 30, 40, 50];
    uint256[] internal maxAmounts = [10, 10, 10, 10, 10];
    uint256[] internal publicMax = [10, 10, 10, 10, 10];
    uint256[] internal whitelistMax = [5, 5, 5, 5, 5];


    function run() external {
        vm.startBroadcast();

        nodesale = new Nodesale(
            block.timestamp + 1 minutes,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            ERC20Sample(0xD43d68c446f97f462ACC339b32b686E14A0D6Ce8),
            msg.sender,
            0x2be8c6891f1218ca14fb9676708d8c698ed3c350f656c37ed1e0614811c17477
        );

        vm.stopBroadcast();
    }
}
