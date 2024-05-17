// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

import { NodesaleTest } from "test/NodesaleTest.sol";
import { INodesale } from "src/INodesale.sol";

contract Nodesalebuy is NodesaleTest {
    function setUp() external {
        fixture();
    }

    modifier validateNodeType(uint8 nodeType) {
        vm.assume(nodeType <= 5);
        vm.assume(nodeType != 0);
        _;
    }

    function test_WhenNodeTypeIsNotExist() external {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.buy(0, 1, emptyRefferalCode);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.buy(6, 1, emptyRefferalCode);
    }

    function test_WhenAmountIsZero() external {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(INodesale.InvalidAmountToBuy.selector);

        nodesale.buy(1, 0, emptyRefferalCode);
    }

    function test_WhenAmountIsHigherThanMaxBuyForUser(uint8 nodeType) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(INodesale.ExceedsMaxAllowedNodesPerUser.selector);

        nodesale.buy(nodeType, 6, emptyRefferalCode);
    }

    function test_WhenAmountIsHigherThanMaxAllowedNodesToBuy(uint8 nodeType) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        // it reverts
        vm.expectRevert(INodesale.MaximumLimitReached.selector);

        nodesale.buy(nodeType, 11, emptyRefferalCode);
    }

    function test_WhenUserDoesntHaveEnoughWrappedEtherForBuyNodes(uint8 nodeType) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        weth.transfer(chuck, weth.balanceOf(alice) - 9);

        // it reverts
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 9, nodesale.prices(nodeType))
        );

        nodesale.buy(nodeType, 1, emptyRefferalCode);
    }

    function test_WhenUserTryToPurchaseBeforeSaleStarts(uint8 nodeType) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        vm.warp(nodesale.startTime() - 1);

        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale.buy(nodeType, 1, emptyRefferalCode);
    }

    function test_WhenUserTryToBuyAfterSaleFinished(uint8 nodeType) external validateNodeType(nodeType) {
        vm.startPrank(alice);

        vm.warp(nodesale.endTime() + 1);

        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale.buy(nodeType, 1, emptyRefferalCode);
    }

    function test_WhenUserBuyNodesWithoutRefferalCode(uint8 nodeType, uint8 amount)
        external
        validateNodeType(nodeType)
    {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= nodesale.publicMax(nodeType));
        vm.assume(amount != 0);

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(alice, emptyRefferalCode, amount, nodesale.prices(nodeType) * amount);

        nodesale.buy(nodeType, amount, emptyRefferalCode);

        // it user balance reduced by total price
        assertEq(userBalanceBefore - nodesale.prices(nodeType) * amount, weth.balanceOf(alice));

        // it contract balance increased
        assertEq(contractBalanceBefore + nodesale.prices(nodeType) * amount, weth.balanceOf(address(nodesale)));

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in public sale increased
        assertEq(nodesale.userPublicNodes(alice, nodeType), amount);
    }

    function test_WhenUserBuyWithRefferalCodeWithDiscountButWithoutPercentForOwner(uint8 nodeType, uint8 amount)
        external
        validateNodeType(nodeType)
    {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= nodesale.publicMax(nodeType));
        vm.assume(amount != 0);

        uint256 discount = (nodesale.prices(nodeType) * amount * refferalCodeWithoutPercentForOwner.discountNumerator)
            / refferalCodeWithoutPercentForOwner.discountDenominator;

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(
            alice, refferalCodeWithoutPercentForOwner, amount, nodesale.prices(nodeType) * amount - discount
        );

        nodesale.buy(nodeType, amount, refferalCodeWithoutPercentForOwner);

        // it user balance reduced by total price minus discount
        assertEq(userBalanceBefore - nodesale.prices(nodeType) * amount + discount, weth.balanceOf(alice));

        // it contract balance increased
        assertEq(
            contractBalanceBefore + nodesale.prices(nodeType) * amount - discount, weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in public sale increased
        assertEq(nodesale.userPublicNodes(alice, nodeType), amount);
    }

    function test_WhenUserBuyWithRefferalCodeWithDiscountAndWithPercentForOwner(uint8 nodeType, uint8 amount)
        external
        validateNodeType(nodeType)
    {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 refferalCodeOwnerBalanceBefore = weth.balanceOf(carol);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= nodesale.publicMax(nodeType));
        vm.assume(amount != 0);

        uint256 discount =
            (nodesale.prices(nodeType) * amount * refferalCode.discountNumerator) / refferalCode.discountDenominator;

        uint256 ownerPercent = (nodesale.prices(nodeType) * amount * refferalCode.ownerPercentNumerator)
            / refferalCode.ownerPercentDenominator;

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(alice, refferalCode, amount, nodesale.prices(nodeType) * amount - discount - ownerPercent);

        nodesale.buy(nodeType, amount, refferalCode);

        // it user balance reduced by total price minus discount and owner commission
        assertEq(userBalanceBefore - nodesale.prices(nodeType) * amount + discount, weth.balanceOf(alice));

        // it refferal code owner get commission
        assertEq(refferalCodeOwnerBalanceBefore + ownerPercent, weth.balanceOf(carol));

        // it contract balance increased
        assertEq(
            contractBalanceBefore + nodesale.prices(nodeType) * amount - discount - ownerPercent,
            weth.balanceOf(address(nodesale))
        );

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in public sale increased
        assertEq(nodesale.userPublicNodes(alice, nodeType), amount);
    }

    function test_WhenUserTryToBuyWithRefferalCodeWhichIsNotCorrect(uint8 nodeType, uint256 amount)
        external
        validateNodeType(nodeType)
    {
        uint256 userBalanceBefore = weth.balanceOf(alice);
        uint256 contractBalanceBefore = weth.balanceOf(address(nodesale));

        vm.assume(amount <= nodesale.publicMax(nodeType));
        vm.assume(amount != 0);

        refferalCodeWithoutPercentForOwner.ownerPercentNumerator = 3;

        vm.startPrank(alice);

        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.Bought(alice, refferalCodeWithoutPercentForOwner, amount, nodesale.prices(nodeType) * amount);

        nodesale.buy(nodeType, amount, refferalCodeWithoutPercentForOwner);

        // it user balance reduced by total price without discount
        assertEq(userBalanceBefore - nodesale.prices(nodeType) * amount, weth.balanceOf(alice));

        // it contract balance increased
        assertEq(contractBalanceBefore + nodesale.prices(nodeType) * amount, weth.balanceOf(address(nodesale)));

        // it total amount of bought nodes increased
        assertEq(nodesale.totalNodesSold(nodeType), amount);

        // it bought nodes for user in public sale increased
        assertEq(nodesale.userPublicNodes(alice, nodeType), amount);
    }
}
