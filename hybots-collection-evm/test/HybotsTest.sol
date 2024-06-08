// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Test } from "./Test.sol";
import { Hybots } from "src/Hybots.sol";

contract HybotsTest is Test {
    Hybots internal nft;

    function fixture() internal {
        nft = new Hybots(carol, chuck, "example.com");
    }
}
