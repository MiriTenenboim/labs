// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/// @title Storage
/// @dev Store & retrieve value in a variable
contract Storage {
    uint256 number;

    /// @dev Store value in variable
    /// @param num - value to store
    function store(uint256 num) public {
        number = num;
    }

    /// @dev Return value
    /// @return value of 'number'
    // what is view?
    // view - the function does not change state
    function retrieve() public view returns (uint256) {
        return number;
    }
}
