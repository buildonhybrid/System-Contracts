// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import {NodesaleTest} from "test/NodesaleTest.sol";
import {INodesale} from "src/INodesale.sol";

contract Nodesalewhitelist_buy is NodesaleTest {
    function setUp() external {
        fixture();
    }

    function test_WhenNodeTypeIsNotExist() external {
        vm.startPrank(alice);

        bytes32[] memory proof = getProof(0);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.whitelistBuy(0, 1, 5, emptyReferralCode, proof);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.whitelistBuy(6, 1, 5, emptyReferralCode, proof);
    }

    function test_WhenAmountIsZero(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(INodesale.InvalidAmountToBuy.selector);

        nodesale.whitelistBuy(nodeType, 0, 5, emptyReferralCode, proof);
    }

    function test_WhenAmountIsHigherThanMaxBuyForUser(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(INodesale.ExceedsMaxAllowedNodesPerUser.selector);

        nodesale.whitelistBuy(nodeType, 9, 5, emptyReferralCode, proof);
    }

    function test_WhenAmountIsHigherThanMaxAllowedNodesToBuy(
        uint8 nodeType,
        uint8 amount
    ) external validateNodeType(nodeType) {
        vm.assume(amount > 10);

        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.whitelistBuy(nodeType, amount, 5, emptyReferralCode, proof);
    }

    function test_WhenUserDoesntHaveEnoughWrappedEtherForBuyNodes(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        weth.transfer(chuck, weth.balanceOf(alice) - 9);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                alice,
                9,
                nodesale.prices(nodeType)
            )
        );

        nodesale.whitelistBuy(nodeType, 1, 5, emptyReferralCode, proof);
    }

    function test_WhenUserTryToPurchaseBeforeSaleStarts(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        vm.warp(nodesale.startTime() - 1);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale.whitelistBuy(nodeType, 1, 5, emptyReferralCode, proof);
    }

    function test_WhenProofsAreWrong(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType);

        // it reverts
        vm.expectRevert(INodesale.NotWhitelisted.selector);

        nodesale.whitelistBuy(nodeType, 1, 5, emptyReferralCode, proof);
    }

    function test_WhenMaxAmountForUserIsWrong(
        uint8 nodeType
    ) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it reverts
        vm.expectRevert(INodesale.NotWhitelisted.selector);

        nodesale.whitelistBuy(nodeType, 1, 6, emptyReferralCode, proof);
    }

    function test_WhenUserBuyNodesWithoutReferralCode(
        uint8 nodeType,
        uint8 amount
    ) external validateNodeType(nodeType) {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= 4);
        vm.assume(amount != 0);

        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(
            alice,
            emptyReferralCode,
            amount,
            nodesale.prices(nodeType) * amount
        );

        nodesale.whitelistBuy(nodeType, amount, 5, emptyReferralCode, proof);

        // it user balance reduced by total price
        assertEq(
            userBalanceBefore - nodesale.prices(nodeType) * amount,
            weth.balanceOf(alice)
        );

        // it contract balance increased
        assertEq(
            contractBalanceBefore + nodesale.prices(nodeType) * amount,
            weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in whitelist sale increased
        assertEq(nodesale.userWhitelistNodes(alice, nodeType), amount);
    }

    function test_WhenUserBuyWithReferralCodeWithDiscountButWithoutPercentForOwner(
        uint8 nodeType,
        uint8 amount
    ) external validateNodeType(nodeType) {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= 4);
        vm.assume(amount != 0);

        uint256 discount = (nodesale.prices(nodeType) *
            amount *
            referralCodeWithoutPercentForOwner.discountNumerator) /
            referralCodeWithoutPercentForOwner.discountDenominator;

        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(
            alice,
            referralCodeWithoutPercentForOwner,
            amount,
            nodesale.prices(nodeType) * amount - discount
        );

        nodesale.whitelistBuy(
            nodeType,
            amount,
            5,
            referralCodeWithoutPercentForOwner,
            proof
        );

        // it user balance reduced by total price minus discount
        assertEq(
            userBalanceBefore - nodesale.prices(nodeType) * amount + discount,
            weth.balanceOf(alice)
        );

        // it contract balance increased
        assertEq(
            contractBalanceBefore +
                nodesale.prices(nodeType) *
                amount -
                discount,
            weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in whitelist sale increased
        assertEq(nodesale.userWhitelistNodes(alice, nodeType), amount);
    }

    function test_WhenUserBuyWithReferralCodeWithDiscountAndWithPercentForOwner(
        uint8 nodeType,
        uint8 amount
    ) external validateNodeType(nodeType) {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 referralCodeOwnerBalanceBefore = weth.balanceOf(carol);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= 4);
        vm.assume(amount != 0);

        uint256 price = nodesale.prices(nodeType);

        uint256 discount = (price * amount * referralCode.discountNumerator) /
            referralCode.discountDenominator;

        uint256 ownerPercent = (price *
            amount *
            referralCode.ownerPercentNumerator) /
            referralCode.ownerPercentDenominator;

        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(
            alice,
            referralCode,
            amount,
            price * amount - discount - ownerPercent
        );

        nodesale.whitelistBuy(nodeType, amount, 5, referralCode, proof);

        // it user balance reduced by total price minus discount and owner commission
        assertEq(
            userBalanceBefore - price * amount + discount,
            weth.balanceOf(alice)
        );

        // it referral code owner get commission
        assertEq(
            referralCodeOwnerBalanceBefore + ownerPercent,
            weth.balanceOf(carol)
        );

        // it contract balance increased
        assertEq(
            contractBalanceBefore + price * amount - discount - ownerPercent,
            weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in whitelist sale increased
        assertEq(nodesale.userWhitelistNodes(alice, nodeType), amount);
    }

    function test_WhenUserTryToBuyWithReferralCodeWhichIsNotCorrect(
        uint8 nodeType,
        uint8 amount
    ) external validateNodeType(nodeType) {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= 4);
        vm.assume(amount != 0);

        referralCodeWithoutPercentForOwner.ownerPercentNumerator = 3;

        vm.startPrank(alice);

        bytes32[] memory proof = getProof(nodeType - 1);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(
            alice,
            referralCodeWithoutPercentForOwner,
            amount,
            nodesale.prices(nodeType) * amount
        );

        nodesale.whitelistBuy(
            nodeType,
            amount,
            5,
            referralCodeWithoutPercentForOwner,
            proof
        );

        // it user balance reduced by total price without discount
        assertEq(
            userBalanceBefore - nodesale.prices(nodeType) * amount,
            weth.balanceOf(alice)
        );

        // it contract balance increased
        assertEq(
            contractBalanceBefore + nodesale.prices(nodeType) * amount,
            weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in whitelist sale increased
        assertEq(nodesale.userWhitelistNodes(alice, nodeType), amount);
    }
}
