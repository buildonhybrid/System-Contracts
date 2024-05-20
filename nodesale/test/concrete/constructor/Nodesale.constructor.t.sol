// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Nodesale } from "src/Nodesale.sol";
import { INodesale } from "src/INodesale.sol";
import { NodesaleTest } from "test/NodesaleTest.sol";

contract NodesaleConstructor is NodesaleTest {
    function setUp() external {
        fixture();
    }

    function test_WhenStartTimestampIsLessThanBlockTimestamp() external {
        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale = new Nodesale(
            block.timestamp - 1,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );
    }

    function test_WhenEndTimestampEqualsStartTimestamp() external {
        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale = new Nodesale(
            block.timestamp, block.timestamp, prices, maxAmounts, whitelistMax, publicMax, weth, manager, bytes32(0)
        );
    }

    function test_WhenStartTimestampIsHigherThanEndTimestamp() external {
        // it reverts
        vm.expectRevert(INodesale.InvalidTimestamp.selector);

        nodesale = new Nodesale(
            block.timestamp + 1, block.timestamp, prices, maxAmounts, whitelistMax, publicMax, weth, manager, bytes32(0)
        );
    }

    function test_WhenLengthOfPriceArrayEqualsZero() external {
        uint256[] memory emptyArray;

        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            emptyArray,
            maxAmounts,
            whitelistMax,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );
    }

    function test_WhenMaxAmountsArrayLengthEqualsZero() external {
        uint256[] memory emptyArray;

        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            emptyArray,
            whitelistMax,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );
    }

    function test_WhenWhitelistMaxArrayLengthEqualsZero() external {
        uint256[] memory emptyArray;

        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            emptyArray,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );
    }

    function test_WhenPublicMaxArrayLengthEqualsZero() external {
        uint256[] memory emptyArray;

        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            emptyArray,
            weth,
            manager,
            bytes32(0)
        );
    }

    function test_WhenWethAddressEqualsZero() external {
        // it reverts
        vm.expectRevert(INodesale.UnacceptableValue.selector);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            IERC20(address(0)),
            manager,
            bytes32(0)
        );
    }

    function test_WhenAllArgumentsAreCorrect() external {
        // it emits
        vm.expectEmit(true, true, true, true);
        emit INodesale.SaleTimeUpdated(block.timestamp, block.timestamp + 7 days);

        nodesale = new Nodesale(
            block.timestamp,
            block.timestamp + 7 days,
            prices,
            maxAmounts,
            whitelistMax,
            publicMax,
            weth,
            manager,
            bytes32(0)
        );

        // it owner is set correct
        assertEq(nodesale.owner(), address(this));

        // it state is updated
        assertEq(nodesale.startTime(), block.timestamp);
        assertEq(nodesale.endTime(), block.timestamp + 7 days);
        assertEq(nodesale.merkleRoot(), bytes32(0));
        assertEq(address(nodesale.WETH()), address(weth));
        for (uint8 i = 1; i < 5; i++) {
            assertEq(nodesale.prices(i), prices[i - 1]);
            assertEq(nodesale.maxAmounts(i), maxAmounts[i - 1]);
            assertEq(nodesale.whitelistMax(i), whitelistMax[i - 1]);
            assertEq(nodesale.publicMax(i), publicMax[i - 1]);
        }
        assertEq(nodesale.prices(1), 10);
        assertEq(nodesale.prices(5), 50);
        assertEq(nodesale.whitelistMax(1), 4);
        assertEq(nodesale.whitelistMax(5), 5);
    }
}
