// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LendingProtocolConnectToAave} from "../../src/lendingProtocol/lendingProtocolConnectToAave.sol";
import "../../src/lendingProtocol/bondToken.sol";
import "./ERC20.sol";

contract LendingProtocolTest is Test {
    LendingProtocol lendingProtocol;
    MyERC20 DAI;

    function setUp() public {
        DAI = new MyERC20(100000000);
        lendingProtocol = new LendingProtocol(address(DAI));
    }
    
    function testLendingProtocol() public {
        // Deposit
        address user = vm.addr(1);
        vm.startPrank(user);
        uint256 amountToDeposit = 100;
        DAI.mint(user, amountToDeposit);
        DAI.mint(address(lendingProtocol), 100000000);
        DAI.approve(address(lendingProtocol), amountToDeposit);
        lendingProtocol.deposit(amountToDeposit);
        assertEq(amountToDeposit, lendingProtocol.getLender().amount, "Error");

        // Withdraw
        uint256 amountToWithdraw = 10;
        uint256 amountBefore = lendingProtocol.getLender().amount;
        lendingProtocol.withdraw(amountToWithdraw);
        assertEq(amountBefore - amountToWithdraw, lendingProtocol.getLender().amount, "Error");

        // Borrow
        // 1
        vm.deal(user, 100000000);
        uint256 borrowAmount = 80;
        amountBefore = lendingProtocol.getBorrower().borrow;
        lendingProtocol.borrow{value: 100}(borrowAmount);
        assertEq(amountBefore + borrowAmount, lendingProtocol.getBorrower().borrow, "Error");

        // 2
        borrowAmount = 64;
        amountBefore = lendingProtocol.getBorrower().borrow;
        lendingProtocol.borrow{value: 80}(borrowAmount);
        assertEq(amountBefore + borrowAmount, lendingProtocol.getBorrower().borrow, "Error");
    
        // AddCollateral
        uint256 collateralBefore = lendingProtocol.getBorrower().collateral;
        lendingProtocol.addCollateral{value: borrowAmount}();
        assertEq(collateralBefore + borrowAmount, lendingProtocol.getBorrower().collateral, "Error");

        // RepayBorrow
        // DAI.approve(address(lendingProtocol), amountToDeposit);
        // uint256 amount = lendingProtocol.getBorrower().borrow;
        // lendingProtocol.repayBorrow(borrowAmount);
        // assertEq(amount - borrowAmount, lendingProtocol.getBorrower().borrow, "Error");

        // RemoveCollateral
        // uint256 amountToRemove = 1;
        // amount = lendingProtocol.getBorrower().collateral;
        // lendingProtocol.removeCollateral(amountToRemove);
        // assertEq(amount - amountToRemove, lendingProtocol.getBorrower().collateral, "Error");

    }
}