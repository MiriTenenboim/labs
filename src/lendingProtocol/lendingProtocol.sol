// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "./bondToken.sol";

contract LendingProtocol {

    struct Lender {
        uint256 amount;     // DAI
    }

    struct Borrower {
        uint256 collateral; // ETH
        uint256 borrow;     // DAI
    }

    address owner;

    mapping (address => Lender) public lenders;
    address[] public lendersAddresses;

    mapping (address => Borrower) public borrowers;
    address[] public borrowersAddresses;
    
    BondToken public bondToken;           
    IERC20 public DAI;                  // Borrow token
    // collateralToken;                 // ETH - moved by msg.value to the contract

    uint256 public totalDeposited;      // DAI

    uint256 public maxLTV = 80;
    uint256 public borrowFee = 3;
    uint256 public liquidationThreshold = 90;

    uint256 public WAD = 10 ** 18;

    constructor(address _DAIAddress) {
        owner = msg.sender;

        // DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        DAI = IERC20(_DAIAddress);
        bondToken = new BondToken();
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function getLender() public view returns (Lender memory lender) {
        lender = lenders[msg.sender];
    }

    function getBorrower() public view returns (Borrower memory borrower) {
        borrower = borrowers[msg.sender];
    }

    function percentage(uint256 x, uint256 y) public pure returns(uint256) {
        return (x * y) / 100;
    }

    // Get the current price of 1 ETH in DAI
    function getETHToDAIPrice() public pure returns (uint256 price){
        price = 1;
    }

    // Deposit DAI into the lending protocol and receive bond tokens in return
    function deposit(uint256 amount) public {
        require(amount > 0, "The amount must be greater than zero");

        DAI.transferFrom(msg.sender, address(this), amount);
        bondToken.mint(msg.sender, amount);

        if(lenders[msg.sender].amount == 0)
            lendersAddresses.push(msg.sender);    
        lenders[msg.sender].amount += amount;

        totalDeposited += amount;
    }

    // Unbond bond tokens and receive DAI in return
    function withdraw(uint256 amount) public {
        require(amount <= lenders[msg.sender].amount, "Not enough balance for withdrawal");
        require(DAI.balanceOf(address(this)) >= amount, "Not enough balance for withdrawal");

        bondToken.burn(msg.sender, amount);
        DAI.approve(address(this), amount);
        DAI.transferFrom(address(this), msg.sender, amount);

        lenders[msg.sender].amount -= amount;

        totalDeposited -= amount;
    }

    // Add ETH as collateral to borrow assets from the protocol
    function addCollateral() public payable {
        require(msg.value > 0, "The amount must be greater than zero");
        // deposit ETH to the contract - use receive built-in function

        if(borrowers[msg.sender].collateral == 0)
            borrowersAddresses.push(msg.sender);
        borrowers[msg.sender].collateral += msg.value;
    }

    // Borrow assets from the protocol using the deposited collateral
    function borrow(uint256 borrowAmount) public payable {
        if(msg.value > 0)
            addCollateral();
        uint256 ETHInDAI = borrowers[msg.sender].collateral * getETHToDAIPrice();
        uint256 borrowLimit = percentage(ETHInDAI, maxLTV) - borrowers[msg.sender].borrow;
        
        require(borrowLimit >= borrowAmount, "There is not enough collateral for the loan");

        borrowers[msg.sender].borrow += borrowAmount;

        DAI.approve(address(this), borrowAmount);
        DAI.transferFrom(address(this), msg.sender, borrowAmount);
    }

    function DistributionFee(uint256 fee) private {
        uint256 depositRatio;
        uint256 amountFee;
        
        for(uint i = 0; i < lendersAddresses.length; i++) {
            depositRatio = lenders[lendersAddresses[i]].amount * WAD / totalDeposited;        
            amountFee = fee * depositRatio / WAD;
            DAI.transferFrom(address(this), lendersAddresses[i], amountFee);
        }
    }

    // Repay borrowed assets to reduce debt
    function repayBorrow(uint256 amountToBorrow) public {
        uint256 fee = percentage(amountToBorrow, borrowFee);

        DAI.transferFrom(msg.sender, address(this), amountToBorrow + fee);
        borrowers[msg.sender].borrow -= amountToBorrow;

        DistributionFee(fee);
    }

    // Remove ETH collateral from the protocol
    function removeCollateral(uint256 amount) public payable {
        if (borrowers[msg.sender].borrow > 0)
        {
            uint256 collateralInDAI = borrowers[msg.sender].collateral * getETHToDAIPrice();
            uint256 maxCollateral = (borrowers[msg.sender].borrow * WAD) / ((collateralInDAI - amount) * WAD / 100);
            require(maxCollateral >= maxLTV, "You can not remove this amount");
        }
        
        require(amount <= lenders[msg.sender].amount, "You can not remove this amount");
        borrowers[msg.sender].collateral -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Trigger liquidation of user positions when their collateral value falls below a certain threshold
    function triggerLiquidation() public onlyOwner {
        uint256 collateralInDAI;
        uint256 maxCollateral;
        uint256 collateral;
        uint256 rewardAmount;

        for(uint i = 0; i < borrowersAddresses.length; i++)
        {
            collateralInDAI = borrowers[borrowersAddresses[i]].collateral * getETHToDAIPrice();
            maxCollateral = (borrowers[borrowersAddresses[i]].borrow * WAD) / (collateralInDAI * WAD / 100);
            if(maxCollateral > liquidationThreshold)
            {
                collateral = borrowers[borrowersAddresses[i]].collateral;
                borrowers[borrowersAddresses[i]].collateral = 0;
                rewardAmount = collateral - percentage(collateral, liquidationThreshold);
                harvestRewards(rewardAmount);
            }
        }
    }

    // Harvest rewards accrued by the protocol
    function harvestRewards(uint256 amount) private {
        payable(msg.sender).transfer(amount);
    }
    
    function convertETHToreserveAssets() public onlyOwner {

    }

}