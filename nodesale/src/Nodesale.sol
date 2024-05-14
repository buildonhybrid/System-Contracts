// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Nodesale is Ownable {
    constructor() Ownable(_msgSender()) {

    }
}
