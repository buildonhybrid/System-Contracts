// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test } from "./Test.sol";
import { ERC20Sample } from "test/samples/ERC20Sample.sol";

import { Nodesale } from "src/Nodesale.sol";
import { INodesale } from "src/INodesale.sol";

contract NodesaleTest is Test {
    Nodesale internal nodesale;

    ERC20Sample internal weth;

    uint256[] internal prices = [10, 20, 30, 40, 50];
    uint256[] internal maxAmounts = [10, 10, 10, 10, 10];
    uint256[] internal publicMax = [1, 2, 3, 4, 5];
    uint256[] internal whitelistMax = [1, 2, 3, 4, 5];

    INodesale.ReferralCode internal emptyRefferalCode = INodesale.ReferralCode({
        ownerOfReferralCode: address(0),
        isWithRefferalCode: false,
        ownerPercentNumerator: 0,
        ownerPercentDenominator: 100,
        discountNumerator: 0,
        discountDenominator: 100,
        signature: ""
    });

    INodesale.ReferralCode internal refferalCodeWithoutPercentForOwner;

    INodesale.ReferralCode internal refferalCode;

    function fixture() internal {
        weth = new ERC20Sample();

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );

        airdrop();

        // setup refferal code without owner percent

        bytes memory signature;

        bytes32 message;

        message = keccak256(abi.encodePacked(address(0), uint16(0), uint16(100), uint16(10), uint16(100), uint256(0)));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        signature = abi.encodePacked(r, s, v);

        refferalCodeWithoutPercentForOwner = INodesale.ReferralCode({
            ownerOfReferralCode: address(0),
            isWithRefferalCode: true,
            ownerPercentNumerator: 0,
            ownerPercentDenominator: 100,
            discountNumerator: 10,
            discountDenominator: 100,
            signature: signature
        });

        // setup refferal code with owner percent

        message = keccak256(abi.encodePacked(carol, uint16(5), uint16(100), uint16(10), uint16(100), uint256(0)));

        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(privateKey, message);

        signature = abi.encodePacked(r1, s1, v1);

        refferalCode = INodesale.ReferralCode({
            ownerOfReferralCode: carol,
            isWithRefferalCode: true,
            ownerPercentNumerator: 5,
            ownerPercentDenominator: 100,
            discountNumerator: 10,
            discountDenominator: 100,
            signature: signature
        });
    }

    function airdrop() private {
        for (uint8 i; i < actors.length; i++) {
            weth.transfer(actors[i], 1000 ether);

            vm.prank(actors[i]);
            weth.approve(address(nodesale), UINT256_MAX);
        }
    }
}
