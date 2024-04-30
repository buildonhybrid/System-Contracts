// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IWrappedHybrid {
    /// @notice Emits when user deposit native tokens(ether) to the contract (wrap).
    /// @param user Address of user who deposited native token.
    /// @param amount Amount of the deposited tokens in wei.
    event Deposited(address user, uint256 amount);

    /// @notice Emits when user withdraw native tokens from contract (unwrap).
    /// @param user Address of user who withdraw native token.
    /// @param amount Amount of the withdrawn tokens in wei.
    event Withdrawn(address user, uint256 amount);

    /// @notice Insufficient sender balance.
    /// @param sender Address of the sender.
    /// @param amount Required amount which is larger then sender balance.
    error InsufficientBalance(address sender, uint256 amount);

    /// @notice Deposit Ether to the contract to get wrapped token.
    function deposit() external payable;

    /// @notice Deposit wrapped tokens to get deposited ether.
    /// @param amount Amount of Ether which will be withdrawn.
    function withdraw(uint256 amount) external;
}
