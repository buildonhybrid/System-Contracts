// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import { INodesale } from "./INodesale.sol";

/*
 * @title Nodesale
 * @author Cowchain
 * @notice Implementation of the smart contract for make sale nodes. There is
 *      opportunity to list a lot of types of node with custom price, max amount to
 *      buy and merkle proofs for whitelist sale. Also there is implemented system
 *      of refferal codes which allows to buy with discounts and percent rewards
 *      for reffferal code owner.
 */
contract Nodesale is INodesale, Ownable, Pausable {
    using SafeERC20 for IERC20;

    /// @notice Timestamp of start of the node sale.
    uint256 public immutable startTime;

    /// @notice Timestamp of end of the node sale.
    uint256 public immutable endTime;

    /// @notice Root proofs for whitelist sale.
    bytes32 public immutable merkleRoot;

    /// @notice Address of the Wrapped Ether.
    IERC20 public immutable WETH;

    /// @notice Address of manager who is able to add new refferal codes.
    address public manager;

    /// @notice Nonce for invalidate referral codes.
    uint256 public referralCodeNonce;

    /// @notice Number of total sold nodes for every type.
    mapping(uint8 => uint256) public totalNodesSold;

    /// @notice Number of bought nodes from public sale per every user.
    mapping(address => mapping(uint8 => uint256)) public userPublicNodes;

    /// @notice Collection of prices for nodes per every type of node.
    mapping(uint8 => uint256) public prices;

    /// @notice Collection of max amounts of total nodes to buy per every type of node.
    mapping(uint8 => uint256) public maxAmounts;

    /// @notice Collection of max amounts to buy in whitelist sale per every type of node.
    mapping(uint8 => uint256) public whitelistMax;

    /// @notice Collection of max amounts to buy in public sale per every type of node.
    mapping(uint8 => uint256) public publicMax;

    modifier checkSaleState(uint8 nodeType, uint256 amount) {
        if (block.timestamp < startTime || block.timestamp > endTime) {
            revert InvalidTimestamp();
        }

        if (amount == 0) {
            revert InvalidAmountToBuy();
        }

        if (amount + totalNodesSold[nodeType] > maxAmounts[nodeType]) {
            revert MaximumLimitReached();
        }

        _;
    }

    /// @notice Constructor
    /// @param _startTime Timestamp of the sale start.
    /// @param _endTime Timestamp of the sale end.
    /// @param _price Collection of prices for every type of node in wei.
    /// @param _maxAmount Collection of max amount to buy for every type of node in wei.
    /// @param _whitelistMax Collection of max amount to buy in whitelist sale per user for every type of node in wei.
    /// @param _publicMax Collection of max amount to buy in public sale per user for every type of node in wei.
    /// @param weth Address of the Wrapped Ether.
    /// @param _merkleRoot Proofs for whitelist sale.
    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] memory _price,
        uint256[] memory _maxAmount,
        uint256[] memory _whitelistMax,
        uint256[] memory _publicMax,
        IERC20 weth,
        address _manager,
        bytes32 _merkleRoot
    ) Ownable(_msgSender()) {
        if (_startTime < block.timestamp || _endTime <= _startTime) {
            revert InvalidTimestamp();
        }

        if (address(weth) == address(0) || _manager == address(0)) {
            revert UnacceptableValue();
        }

        if (_price.length == 0 || _maxAmount.length == 0 || _whitelistMax.length == 0 || _publicMax.length == 0) {
            revert UnacceptableValue();
        }

        for (uint8 i; i < _price.length; i++) {
            // set price for every type of node
            prices[i + 1] = _price[i];

            // set max amount to buy for every type of node
            maxAmounts[i + 1] = _maxAmount[i];

            // set whitelist max for every type of node
            whitelistMax[i + 1] = _whitelistMax[i];

            // set public max for every type of node
            publicMax[i + 1] = _publicMax[i];
        }

        startTime = _startTime;
        endTime = _endTime;
        merkleRoot = _merkleRoot;
        WETH = weth;
        manager = _manager;

        emit SaleTimeUpdated(startTime, endTime);
    }

    /// @inheritdoc INodesale
    function buy(uint8 nodeType, uint256 amount, INodesale.ReferralCode memory referralCode)
        external
        checkSaleState(nodeType, amount)
        whenNotPaused
    {
        if (userPublicNodes[_msgSender()][nodeType] + amount > publicMax[nodeType]) {
            revert ExceedsMaxAllowedNodesPerUser();
        }

        uint256 totalPrice = amount * prices[nodeType];

        if (referralCode.isWithRefferalCode == true) {
            address signatureSigner = ECDSA.recover(
                keccak256(
                    abi.encodePacked(
                        referralCode.ownerOfReferralCode,
                        referralCode.ownerPercentNumerator,
                        referralCode.ownerPercentDenominator,
                        referralCode.discountNumerator,
                        referralCode.discountDenominator,
                        referralCodeNonce
                    )
                ),
                referralCode.signature
            );

            if (signatureSigner == manager) {
                uint256 discount = (totalPrice * referralCode.discountNumerator) / referralCode.discountDenominator;
                uint256 ownerPercent;

                if (referralCode.ownerOfReferralCode != address(0)) {
                    ownerPercent =
                        (totalPrice * referralCode.ownerPercentNumerator) / referralCode.ownerPercentDenominator;

                    WETH.safeTransferFrom(_msgSender(), referralCode.ownerOfReferralCode, ownerPercent);
                }

                totalPrice = totalPrice - discount - ownerPercent;
            }
        }

        WETH.safeTransferFrom(_msgSender(), address(this), totalPrice);

        unchecked {
            totalNodesSold[nodeType] += amount;

            userPublicNodes[_msgSender()][nodeType] += amount;
        }

        emit Bought(_msgSender(), referralCode, amount, totalPrice);
    }

    /// @inheritdoc INodesale
    function pause() external onlyOwner {
        _pause();
    }

    /// @inheritdoc INodesale
    function unpause() external onlyOwner {
        _unpause();
    }
}
