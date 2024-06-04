// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


// Deploy address = 0xca61f2a7dDF247d558331f8B02E458dF5840b4b6
contract CounterV1 {
    uint256 public count;

    function inc() external {
        count += 1;
    }
}