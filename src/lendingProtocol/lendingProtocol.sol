// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/console.sol";

contract LendingProtocol {

    struct User {
        uint256 DAIDeposited;
        uint256 bondTokens;
        uint256 collateralETH;
        uint256 DAIBorrowed;
    }

    IERC20 public DAI;
    IERC20 public ETH;

    mapping(address => User) public users;

}
