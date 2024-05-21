// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {NodesaleTest} from "test/NodesaleTest.sol";
import {INodesale} from "src/INodesale.sol";

contract Nodesalewithdraw is NodesaleTest {
    function setUp() external {
        fixture();
    }

    function test_buy() external {
        vm.startPrank(alice);

        bytes32[] memory proofs = getProof(0);

        nodesale.merkleRoot();

        nodesale.whitelistBuy(1, 2, 5, emptyReferralCode, proofs);
    }
}
