// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract Target {

    function isContract(address account) public view returns (bool) {
        uint size;

        assembly {
            size := extcodesize(account)
        }

        return size > 0;
    }

    bool public pwned = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}

contract TestTargetFailedAttack is Test {
    Target public target;

    function setUp() public {
        target = new Target();
    }

    function testPwn() public {
        vm.expectRevert("no contract allowed");

        target.protected();
    }
}

contract Attack {
    bool public isContract;
    address public addr;

    constructor(address target) {
        isContract = Target(target).isContract(address(this));
        addr = address(this);
        Target(target).protected();
    }
}
