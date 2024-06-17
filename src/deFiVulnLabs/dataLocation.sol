// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract Array {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => UserInfo) public usersInfo;

    function updateRewardDebt(uint256 _rewardDebt) public {
        UserInfo memory userInfo = usersInfo[msg.sender];
        userInfo.rewardDebt = _rewardDebt;
    }

    function updateRewardDebtFixed(uint256 _rewardDebt) public {
        UserInfo storage userInfo = usersInfo[msg.sender];
        userInfo.rewardDebt = _rewardDebt;
    }
}

contract TestArray is Test {
    Array public array;

    function setUp() public {
        array = new Array();
    }

    function testDataLocation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        vm.deal(address(alice), 1 ether);
        vm.deal(address(bob), 1 ether);

        //vm.startPrank(alice);
        array.updateRewardDebt(100);
        (uint amount, uint rewardDebt) = array.usersInfo(address(this));
        console.log("updateRewardDebt");
        console.log("rewardDebt", rewardDebt);
        console.log("amount", amount);

        array.updateRewardDebtFixed(100);
        (uint updatedAmount, uint updatedRewardDebt) = array.usersInfo(address(this));
        console.log("updateRewardDebtFixed");
        console.log("rewardDebt", updatedRewardDebt);
        console.log("amount", updatedAmount);
    }

    receive() external payable {}
}