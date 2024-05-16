// SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "forge-std/interfaces/IERC20.sol";
import "./bondToken.sol";
import "./aa.sol";

contract LendingProtocol {

    struct Lender {
        uint256 amount;
    }

    struct Borrower {
        uint256 collateral;
        uint256 borrow;
    }

    address owner;

    mapping (address => Lender) public lenders;
    address[] public lendersAddresses;

    mapping (address => Borrower) public borrowers;
    address[] public borrowersAddresses;
    
    BondToken public bondToken;           
    IERC20 public DAI;                  // Borrow token
    // collateralToken;                 // ETH - moved by msg.value to the contract

    uint256 public maxLTV = 80;

    address public constant ethUsdPriceFeed = 0x514910771AF9Ca656af840dff83E8264EcF986CA;

    constructor() {
        owner = msg.sender;

        DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        bondToken = new BondToken();
    }

     modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    function percentage(uint256 x, uint256 y) public pure returns(uint256) {
        return (x * y) / 100;
    }

    // Deposit DAI into the lending protocol and receive bond tokens in return
    function deposit(uint256 amount) public {
        require(amount > 0, "The amount must be greater than zero");

        DAI.transferFrom(msg.sender, address(this), amount);
        bondToken.mint(msg.sender, amount);

        if(lenders[msg.sender].amount == 0)
            lendersAddresses.push(msg.sender);    
        lenders[msg.sender].amount += amount;
    }

    // Unbond bond tokens and receive DAI in return
    function withdraw(uint256 amount) public {
        require(amount <= lenders[msg.sender].amount, "Not enough balance for withdrawal");

        bondToken.burn(msg.sender, amount);
        DAI.transferFrom(address(this), msg.sender, amount);

        lenders[msg.sender].amount -= amount;
    }

    // Add ETH as collateral to borrow assets from the protocol
    function addCollateral() public payable {
        require(msg.value > 0, "The amount must be greater than zero");

        // deposit ETH to the contract - use receive built-in function
        if(borrowers[msg.sender].collateral == 0)
            borrowersAddresses.push(msg.sender);
        borrowers[msg.sender].collateral += msg.value;
    }

    function borrow(uint256 borrowAmount) public payable {
        if(msg.value > 0)
            addCollateral();
        uint256 borrowLimit = percentage(borrowers[msg.sender].collateral, maxLTV) - borrowers[msg.sender].borrow;
        require(borrowLimit >= borrowAmount, "There is not enough collateral for the loan");
        DAI.transferFrom(address(this), msg.sender, borrowAmount);
    }

    function returnBorrow() public {

    }

    function removeCollateral() public {

    }

    function triggerLiquidation() public onlyOwner {

    }

    function harvestRewards() public onlyOwner {

    }
    
    function convertETHToreserveAssets() public onlyOwner {

    }

    // Function to fetch the ETH/USD price from Chainlink oracle
  function getEthUsdPrice() public view returns (uint256) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(ethUsdPriceFeed);
    (, int256 ethPrice, , , ) = priceFeed.latestRoundData();
    // Assuming positive price value
    require(ethPrice > 0, "Invalid ETH price received");
    // Convert price to uint (remove decimals) considering signed int
    return uint256(ethPrice);
  }

  // Function to estimate DAI/ETH price (assuming 1 DAI = 1 USD)
  function getDaiEthPrice() public view returns (uint256) {
    uint256 ethUsdPrice = getEthUsdPrice();
    // Assuming 1 DAI = 1 USD, so DAI/ETH = ETH/USD
    return ethUsdPrice;
  }

}