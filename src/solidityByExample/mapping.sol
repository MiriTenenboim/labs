// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mapping {
    mapping (address => uint256) public newMap;

    function getValue(address addr) public view returns (uint256) {
        return newMap[addr];
    }

    function setValue(address addr, uint256 value) public {
        newMap[addr] = value;
    }

    function deleteValue(address addr) public {
        delete newMap[addr];
    }
}

contract NestedMapping {
    mapping (address => mapping(uint256 => bool)) public newNestedMap;

    function getValue(address addr, uint256 index) public view returns (bool) {
        return newNestedMap[addr][index];
    }

    function setValue(address addr, uint256 index, bool value) public {
        newNestedMap[addr][index] = value;
    }

    function deleteValue(address addr, uint256 index) public {
        delete newNestedMap[addr][index];
    }
}