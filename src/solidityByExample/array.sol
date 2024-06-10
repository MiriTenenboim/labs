// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Array {
    uint256[] public arr;

    uint256[] public newArr = [1, 2, 3];
    uint256[10] public sizedArray;

    function getLength() public view returns (uint256) {
        return arr.length;
    }

    function getValue(uint256 index) public view returns (uint256) {
        return arr[index];
    }

    function getArr(address addr, uint256 value) public view returns (uint256[] memory) {
        return arr;
    }

    function push(uint256 value) public {
        arr.push(value);
    }

    function pop() public {
        arr.pop();
    }

    function deleteValue(uint256 index) public {
        delete arr[index];
    }

    function examples() external {
        uint256[] memory createdArr = new uint256[](5);
    }
}