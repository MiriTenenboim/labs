// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {APIConsumer} from "../../src/aaa.sol";

contract APIConsumerTest is Test {
    APIConsumer _APIConsumer;

    function setUp() public {
        _APIConsumer = new APIConsumer();
    }
    
    function testAAA() public {
        bytes32 requestId = _APIConsumer.requestVolumeData();
        console.log(requestId);
    }
}