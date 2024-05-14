// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {INodesale} from "./INodesale.sol";

contract Nodesale is INodesale, Ownable, Pausable {
    using SafeERC20 for IERC20;

    uint256 public totalNodesSold;

    uint256 public immutable startTime;
    uint256 public immutable endTime;
    bytes32 public immutable merkleRoot;
    IERC20 public immutable WETH;

    mapping(address => mapping(uint8 => uint256)) public userPublicNodes;

    mapping(uint8 => uint256) public prices;

    mapping(uint8 => uint256) public maxAmounts;

    mapping(uint8 => uint256) public whitelistMax;

    mapping(uint8 => uint256) public publicMax;

    modifier checkSaleState(uint8 nodeType, uint256 amount) {
        if (block.timestamp >= startTime && block.timestamp <= endTime) {
            revert InvalidTimestamp();
        }

        if (amount + totalNodesSold <= maxAmounts[nodeType])
            revert MaximumLimitReached();

        if (amount > 0) revert InvalidAmountToBuy();
        _;
    }

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256[] memory _price,
        uint256[] memory _maxAmount,
        uint256[] memory _whitelistMax,
        uint256[] memory _publicMax,
        IERC20 weth,
        bytes32 _merkleRoot
    ) Ownable(_msgSender()) {
        if (_startTime > block.timestamp && _endTime > _startTime) {
            revert InvalidTimestamp();
        }

        if (address(weth) == address(0)) revert UnacceptableValue();

        for (uint8 i; i < _price.length; ++i) {
            // set price for every type of node
            prices[i] = _price[i];

            // set max amount to buy for every type of node
            maxAmounts[i] = _maxAmount[i];

            // set whitelist max for every type of node
            whitelistMax[i] = _whitelistMax[i];

            // set public max for every type of node
            publicMax[i] = _publicMax[i];
        }

        startTime = _startTime;
        endTime = _endTime;
        merkleRoot = _merkleRoot;
        WETH = weth;

        emit SaleTimeUpdated(startTime, endTime);
    }

    function buy(
        uint8 nodeType,
        uint256 amount,
        bytes32 referralCode
    ) external onlyOwner checkSaleState(nodeType, amount) whenNotPaused {
        if (
            userPublicNodes[_msgSender()][nodeType] + amount >
            publicMax[nodeType]
        ) revert ExceedsMaxAllowedNodesPerUser();

        uint256 totalPrice = amount * prices[nodeType];

        WETH.safeTransferFrom(_msgSender(), address(this), totalPrice);

        unchecked {
            totalNodesSold += amount;

            userPublicNodes[_msgSender()][nodeType] += amount;
        }
    }

    /**
     * @dev To pause the presale
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev To unpause the presale
     */
    function unpause() external onlyOwner {
        _unpause();
    }
}
