// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface INodesale {
    struct ReferralCode {
        address ownerOfReferralCode;
        bool isWithRefferalCode;
        uint16 ownerPercentNumerator;
        uint16 ownerPercentDenominator;
        uint16 discountNumerator;
        uint16 discountDenominator;
        bytes signature;
    }

    /// @notice Emits when timestamp of start and end of the sale are updated.
    event SaleTimeUpdated(uint256 indexed _start, uint256 indexed _end);

    /// @notice Emits when someone bought nodes.
    event Bought(address indexed user, ReferralCode referralCode, uint256 indexed nodesBought, uint256 amountPaid);

    /// @notice Emits when owner withdraw collected tokens.
    event Withdrawn(address to, uint256 value);

    error InvalidTimestamp();

    error MaximumLimitReached();

    error InvalidAmountToBuy();

    error UnacceptableValue();

    error ExceedsMaxAllowedNodesPerUser();

    /// @notice Main function for buy nodes in public sale.
    /// @param nodeType Number of the node type.
    /// @param amount Amount of nodes to be bought in one time.
    /// @param refferalCode Refferal code which has all attributes for setup discounts.
    function buy(uint8 nodeType, uint256 amount, ReferralCode memory refferalCode) external;

    /// @notice Withdraw collected wrapped ether by owner.
    /// @param to Address which will receive collected tokens.
    function withdraw(address to) external;

    /**
     * @dev To pause the presale
     */
    function pause() external;

    /**
     * @dev To unpause the presale
     */
    function unpause() external;
}
