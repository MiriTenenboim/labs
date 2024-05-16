// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Interface for interacting with Chainlink's Aggregator (price feed)
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function getTimestamp() external view returns (uint256);

  function getPrice() external view returns (int256);
}