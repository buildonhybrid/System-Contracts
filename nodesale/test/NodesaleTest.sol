// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Test } from "./Test.sol";
import { ERC20Sample } from "test/samples/ERC20Sample.sol";

import { Nodesale } from "src/Nodesale.sol";
import { INodesale } from "src/INodesale.sol";

contract NodesaleTest is Test {
    Nodesale internal nodesale;

    ERC20Sample internal weth;

    bytes32[] internal proofs = ['0xbaf0ecf5695b06ac7108e988700adef0c1d056595ffbce97187791a162f57fab'];

    uint256[] internal prices = [10, 20, 30, 40, 50];
    uint256[] internal maxAmounts = [10, 10, 10, 10, 10];
    uint256[] internal publicMax = [1, 2, 3, 4, 5];
    uint256[] internal whitelistMax = [4, 5, 5, 5, 5];

    INodesale.ReferralCode internal emptyReferralCode = INodesale.ReferralCode({
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
            0xbaf0ecf5695b06ac7108e988700adef0c1d056595ffbce97187791a162f57fab
        );

        airdrop();

        // setup referral code without owner percent

        bytes memory signature;

        bytes32 message;

        message = keccak256(abi.encodePacked(address(0), uint16(0), uint16(100), uint16(10), uint16(100), uint256(0)));

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

        message = keccak256(abi.encodePacked(carol, uint16(5), uint16(100), uint16(10), uint16(100), uint256(0)));

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

    function setProofs() private {
        proofs = [0xbaf0ecf5695b06ac7108e988700adef0c1d056595ffbce97187791a162f57fab,
    0x5605ecc6fd5702cce6a45ef2ea664b4d0157feabec2fcf11fb7ada7c23e10b30,
    0x0c8e6019593b184993a047a09dbf65e40168edf7214e80e52d00d008e1a05cd7,
    0xe4045fe048fac83da28186bd868e8a307d76e5e0bbf78f70dad77286d61dd643,
    0xca89a7896a8a13666b0c0eb0b807cd30cfbebb7bd59db25344b671ad8da8e457,
    0x80c77cb740a0238b9b80ddd455fb36d1af6b75ef3823f84eab7803bb3386d82f,
    0x0dfb602edcaf9fb76c094367dd0515d340d0b1a43c5ba2d3f74d2512cb54ae4e,
    0xcecafa9238410e491df23d5819c3900115ba4746413075368c7e54f098334a9b,
    0x598c886d6c0730d84ad996a96d17560824a342e2beeafbda3db408cba9d5a18a,
    0xa6a0999c3ac8ce49efb0493fbb816b0f6e9ae2777af25fb8840b8309dd370f4b,
    0x4282ed3ed78abe8ac5d826aefa85296cd3b468fbc3607ac4086cbd5d784fa9e4,
    0x549d533cad98e5e91008e01daadf63789a3b3f852e856163b68a1a405c354d23,
    0x3a4f36431ea70f06298c486a09a6ae381092786ebdd32648945708c3128e0915,
    0xdcf67ae6840e6098f5b37b818771b35fb9530482a37790d59b6717a96a552758,
    0xfe6af5b84d86f508baa79fefd85316eb08f1ef5b4e9a556ff2eaa616b3610cea,
    0xeb1cd22210b0678ece0f2a923702b2a5d6b82f7bab06ef4e5cf0ecdc83871eb8,
    0xdcb030e6bee2644e1cdb8d429df86b8502a0ea9aeffc81deafeb6e87a9d41b89,
    0xd734b058e14685f6f4b45dabe5000d5ae7fa8242a2dea027aaea5ae2c90c5912,
    0xc923256b44e9604592e59297b067741bfcec879e1c2ac0ff90bf43f7ba9b1421,
    0xadd1128cd1e229e1793acc7c79d278e08ff808b0b50c20b3a4b504a26b53d896,
    0xabb9e584b742d13f9d5a7f4c6983dbbe6d93f65510bef6092e8b421c59dc1cc5,
    0x9c3abc62cdc5cedacf6a4099686ffb9a1251d15bc2595e066c477c03a3bb163d,
    0x8000c6bc7a11b293e8ea1b53bdc40c9e3d46bc5166043955b978679e81f08a1d,
    0x7fa28e0a93564c9665b19b23b8a217dc9f181d70f6167c8b94914e99cdf8dc1c,
    0x414bd05e988122cb2f8c47d2e174976f3a5add75b4483b99abc2a03c5479b7d5,
    0x3c740a5f382f3639762f84f733541c725ae890bf8de9e62c1d50a350df9acc21,
    0x31d123c86122343b32cb13b7755354b2167c820ddc3f10e4338f726f38f579dd,
    0x21087b0746032c0136f14322dbe7b6920b63376cb1ed171a55540c9484a95a2c,
    0x0577559fba1b76f18938363f49922d57811caff4d4dcb525d1759289ae16d3ca];
    }
}
