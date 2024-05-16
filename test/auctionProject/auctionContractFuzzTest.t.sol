// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {AuctionContract} from "../../src/auctionProject/auctionContract.sol";
import "./MyERC721.sol";

contract AuctionContractTest is Test {
    AuctionContract public auctionContract;
    MyERC721 tokenNFT;

    function setUp() public {
        tokenNFT = new MyERC721();
        auctionContract = new AuctionContract(address(tokenNFT));
    }

    receive() external payable {}

    function testAuction(uint256 tokenId,uint256 endAt, uint256 bidAmountStart,uint256 bidAmount1, uint256 bidAmount2) public payable {
        // Start auction
        // uint256 tokenId = 1;
        // uint256 bidAmount = 100;
        // uint256 endAt = block.timestamp + 3600;
        // vm.assume(tokenId > 0);
        // vm.assume(endAt > block.timestamp);
        // vm.assume(bidAmountStart > 0);
        // tokenNFT.mint(address(this), tokenId);
        // tokenNFT.approve(address(auctionContract), tokenId);
        // console.log("Start auction");
        // uint256 auctionCounter = auctionContract.startAuction{value: bidAmountStart}(tokenId, endAt);

        // assertEq(tokenNFT.ownerOf(tokenId), address(auctionContract), "False");

        // Place bid
        // 1
        // bidAmount = 150;
        // vm.assume(bidAmount1 > bidAmountStart);
        // address user = vm.addr(1);
        // vm.startPrank(user);
        // // vm.warp(3000);
        // vm.deal(user, bidAmount1);
        // console.log("Place bid");
        // auctionContract.placeBid{value: bidAmount1}(auctionCounter);

        // assertEq(auctionContract.getAuction(auctionCounter).highestBidder, user, "False");
        // assertEq(auctionContract.getAuction(auctionCounter).highestBid, bidAmount1, "False");
        // vm.stopPrank();

        // 2
        // bidAmount = 170;
        // vm.assume(bidAmount2 > bidAmount1);
        // user = vm.addr(2);
        // vm.startPrank(user);
        // // vm.warp(3000);
        // vm.deal(user, bidAmount2);
        // console.log("Place bid");
        // auctionContract.placeBid{value: bidAmount2}(auctionCounter);

        // assertEq(auctionContract.getAuction(auctionCounter).highestBidder, user, "False");
        // assertEq(auctionContract.getAuction(auctionCounter).highestBid, bidAmount2, "False");
        // vm.stopPrank();

        // End auction
        // console.log("End auction");
        // vm.warp(4000);
        // console.log("Seller balance before", auctionContract.getAuction(auctionCounter).seller.balance);
        // console.log("Owner before", tokenNFT.ownerOf(tokenId));
        // console.log("contract address", address(auctionContract));
        // auctionContract.endAuction(auctionCounter);
        // console.log("Contract balance after transfer:", address(auctionContract).balance);
        // console.log("Seller", auctionContract.getAuction(auctionCounter).seller);
        // console.log(tokenNFT.ownerOf(tokenId));
        // console.log("Seller balance after", auctionContract.getAuction(auctionCounter).seller.balance);

        // assertEq(tokenNFT.ownerOf(tokenId), auctionContract.getAuction(auctionCounter).highestBidder);
    }
}
