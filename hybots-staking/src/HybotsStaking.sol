// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract HybotsStaking is Ownable {
    IERC721 public hybotsCollection;

    error UnaceptableValue();

    constructor(IERC721 hybotsCollection_, address initialOwner) Ownable(initialOwner) {
        if (address(hybotsCollection_) == address(0)) revert UnaceptableValue();

        hybotsCollection = hybotsCollection_;
    }
}
