// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LendingProtocol} from "../../src/lendingProtocol/lendingProtocol.sol";
import "../../src/lendingProtocol/bondToken.sol";

contract LendingProtocolTest is Test {
    LendingProtocol lendingProtocol;

    function setUp() public {
        lendingProtocol = new LendingProtocol();
    }
    
}