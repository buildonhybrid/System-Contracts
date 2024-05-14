// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface INodesale {
    event SaleTimeUpdated(uint256 indexed _start, uint256 indexed _end);

    error InvalidTimestamp();

    error MaximumLimitReached();

    error InvalidAmountToBuy();

    error UnacceptableValue();

    error ExceedsMaxAllowedNodesPerUser();

    function buy(uint8 nodeType, uint256 amount, bytes32 referralCode) external;
}
