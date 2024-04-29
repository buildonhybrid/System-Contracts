// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title Wrapped Hybrid token.
 * @notice An implementation of ERC20 token.
 */
contract WrappedHybrid is ERC20, Ownable, ERC20Permit {
    constructor(address initialOwner)
        ERC20("WrappedHybrid", "WHD")
        Ownable(initialOwner)
        ERC20Permit("WrappedHybrid")
    {}

    /// @notice Mint new tokens and increase totalSupply. 
    /// @param to Address which will get minted tokens. 
    /// @param amount Amount of tokens which will be minted.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
