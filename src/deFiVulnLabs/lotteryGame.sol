// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";

contract LotteryGame {
    uint256 public prize;
    address public winner;
    address public admin = msg.sender;

    modifier isAdmin {
        if (msg.sender == refree())
            _;
        else
            getWinner();
    }

    function refree() internal view returns (address user) {
        assembly {
            user := sload(2)
        }
    }

    function pickWinner(address _winner) public isAdmin {
        assembly {
            sstore(2, _winner)
        }
        winner = _winner;
    }

    function getWinner() public view returns (address){
        return winner;
    }
}

contract TestLotteryGame is Test {
    LotteryGame lotteryGame;

    function setUp() public {
        lotteryGame = new LotteryGame();
    }

    function testLotteryGame() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        console.log("alice", address(alice));
        console.log("bob", address(bob));

        vm.startPrank(alice);

        console.log("pick winner not allowed");
        lotteryGame.pickWinner(address(alice));

        console.log("winner: ", lotteryGame.winner());

        console.log("admin before: ", lotteryGame.admin());

        vm.stopPrank();

        console.log("pick winner allowed");
        lotteryGame.pickWinner(address(bob));
        console.log("winner: ", lotteryGame.winner());

        console.log("admin after: ", lotteryGame.admin());
    }
}