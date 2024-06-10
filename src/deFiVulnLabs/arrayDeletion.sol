// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract ArrayDeletionWithBug {
    uint256[] public array = [1, 2, 3, 4];

    function getLength() public view returns (uint256) {
        return array.length;
    }

    function deleteValue(uint256 index) public {
        require(index < array.length, "index out of range");
        delete array[index];
    }
}

contract ArrayDeletion {
    uint256[] public array = [1, 2, 3, 4];

    function getLength() public view returns (uint256) {
        return array.length;
    }

    function deleteValue(uint256 index) public {
        require(index < array.length, "index out of range");
        
        array[index] = array[array.length - 1];
        array.pop();
    }
}

// Tests
contract TestArrayDeletionWithBug is Test {
    ArrayDeletionWithBug arrayDeletionWithBug;

    function setUp() public {
        arrayDeletionWithBug = new ArrayDeletionWithBug();
    }

    function testDeleteValue() public {

        console.log("Deletion contract with bug");

        console.log("Before deletion");
        console.log("value", arrayDeletionWithBug.array(0));
        console.log("length", arrayDeletionWithBug.getLength());

        arrayDeletionWithBug.deleteValue(0);

        console.log("After deletion");
        console.log("value", arrayDeletionWithBug.array(0));
        console.log("length", arrayDeletionWithBug.getLength());
    }
}

contract TestArrayDeletion is Test {
    ArrayDeletion arrayDeletion;

    function setUp() public {
        arrayDeletion = new ArrayDeletion();
    }

    function testDeleteValue() public {

        console.log("Deletion contract without bug");

        console.log("Before deletion");
        console.log("value", arrayDeletion.array(0));
        console.log("length", arrayDeletion.getLength());

        arrayDeletion.deleteValue(0);

        console.log("After deletion");
        console.log("value", arrayDeletion.array(0));
        console.log("length", arrayDeletion.getLength());
    }
}
