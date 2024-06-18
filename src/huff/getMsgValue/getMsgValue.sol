// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract GetMsgValue {
    function msgValue() internal view returns (address) {
        return msg.sender;
    }
}