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
    uint256[] internal whitelistMax = [1, 2, 3, 4, 5];


    function run() external {
        vm.startBroadcast();
    
        ERC20Sample token = new ERC20Sample();

        nodesale = new Nodesale(
            block.timestamp + 1 minutes,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            token,
            msg.sender,
            bytes32(0)
        );

        vm.stopBroadcast();
    }
}
