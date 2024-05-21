// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Merkle} from "murky/Merkle.sol";

import {Test} from "./Test.sol";
import {ERC20Sample} from "test/samples/ERC20Sample.sol";

import {Nodesale} from "src/Nodesale.sol";
import {INodesale} from "src/INodesale.sol";

contract NodesaleTest is Test {
    Nodesale internal nodesale;

    ERC20Sample internal weth;

    uint256[] internal prices = [10, 20, 30, 40, 50];
    uint256[] internal maxAmounts = [10, 10, 10, 10, 10];
    uint256[] internal publicMax = [1, 2, 3, 4, 5];
    uint256[] internal whitelistMax = [4, 5, 5, 6, 5];

    INodesale.ReferralCode internal emptyReferralCode =
        INodesale.ReferralCode({
            ownerOfReferralCode: address(0),
            isWithReferralCode: false,
            ownerPercentNumerator: 0,
            ownerPercentDenominator: 100,
            discountNumerator: 0,
            discountDenominator: 100,
            signature: ""
        });

    INodesale.ReferralCode internal referralCodeWithoutPercentForOwner;

    INodesale.ReferralCode internal referralCode;

    modifier validateNodeType(uint8 nodeType) {
        vm.assume(nodeType <= 5);
        vm.assume(nodeType != 0);
        _;
    }

    function fixture() internal {
        weth = new ERC20Sample();

        emit log_address(alice);
        emit log_address(bob);
        emit log_address(carol);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            weth,
            manager,
            getWhitelistRoot()
        );

        airdrop();

        // setup referral code without owner percent

        bytes memory signature;

        bytes32 message;

        message = keccak256(
            abi.encodePacked(
                address(0),
                uint16(0),
                uint16(100),
                uint16(10),
                uint16(100),
                uint256(0)
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, message);

        signature = abi.encodePacked(r, s, v);

        referralCodeWithoutPercentForOwner = INodesale.ReferralCode({
            ownerOfReferralCode: address(0),
            isWithReferralCode: true,
            ownerPercentNumerator: 0,
            ownerPercentDenominator: 100,
            discountNumerator: 10,
            discountDenominator: 100,
            signature: signature
        });

        // setup referral code with owner percent

        message = keccak256(
            abi.encodePacked(
                carol,
                uint16(5),
                uint16(100),
                uint16(10),
                uint16(100),
                uint256(0)
            )
        );

        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(privateKey, message);

        signature = abi.encodePacked(r1, s1, v1);

        referralCode = INodesale.ReferralCode({
            ownerOfReferralCode: carol,
            isWithReferralCode: true,
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

    bytes32[] data = new bytes32[](10);

    function getWhitelistRoot() private returns (bytes32) {
        Merkle merkle = new Merkle();

        data[0] = keccak256(abi.encode(uint8(1), alice, uint256(5)));
        data[1] = keccak256(abi.encode(uint8(2), alice, uint256(5)));
        data[2] = keccak256(abi.encode(uint8(3), alice, uint256(5)));
        data[3] = keccak256(abi.encode(uint8(4), alice, uint256(5)));
        data[4] = keccak256(abi.encode(uint8(5), alice, uint256(5)));
        data[5] = keccak256(abi.encode(uint8(1), bob, uint256(5)));
        data[6] = keccak256(abi.encode(uint8(2), bob, uint256(5)));
        data[7] = keccak256(abi.encode(uint8(3), bob, uint256(5)));
        data[8] = keccak256(abi.encode(uint8(4), bob, uint256(5)));
        data[9] = keccak256(abi.encode(uint8(5), bob, uint256(5)));

        bytes32 root = merkle.getRoot(data);

        return root;
    }

    function getProof(uint256 index) internal returns (bytes32[] memory) {
        Merkle merkle = new Merkle();

        return merkle.getProof(data, index);
    }
}
