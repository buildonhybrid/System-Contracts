// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { IWrappedHybrid } from "src/IWrappedHybrid.sol";

/**
 * @title Wrapped Hybrid token.
 * @notice An implementation of ERC20 token with wrapper.
 */
contract WrappedHybrid is ERC20, IWrappedHybrid, Ownable {
    constructor(address initialOwner) ERC20("WrappedHybrid", "WHD") Ownable(initialOwner) { }

    /// @inheritdoc IWrappedHybrid
    function withdraw(uint256 amount) external {
        address sender = _msgSender();

        if (balanceOf(sender) < amount) {
            revert InsufficientBalance(sender, amount);
        }

        _burn(sender, amount);

        payable(sender).transfer(amount);

        emit Withdrawn(sender, amount);
    }

    /// @inheritdoc IWrappedHybrid
    function deposit() public payable {
        _mint(_msgSender(), msg.value);

        emit Deposited(_msgSender(), msg.value);
    }

    /// @notice Mint new tokens and increase totalSupply.
    /// @param to Address which will get minted tokens.
    /// @param amount Amount of tokens which will be minted.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
