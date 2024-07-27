// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Test} from "./Test.sol";
import {HybotsStaking} from "src/HybotsStaking.sol";
import {ERC721Mock} from "test/mocks/ERC721Mock.sol";

contract HybotsStakingTest is Test {
    HybotsStaking internal staking;

    ERC721Mock internal nft;

    function fixture() internal {
        nft = new ERC721Mock(deployer);

        staking = new HybotsStaking(nft, deployer);

        airdropNFTs();
    }

    function airdropNFTs() public {
        for (uint i = 0; i < actors.length; i++) {
            vm.prank(deployer);
            nft.safeMint(actors[i]);

            vm.prank(actors[i]);
            nft.setApprovalForAll(address(staking), true);
        }
    }
}
