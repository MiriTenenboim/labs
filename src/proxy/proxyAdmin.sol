// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./proxy.sol";

// Deploy address = 0x4D4B33dCBd67BE566aE33d331EebC78195af1B58
contract ProxyAdmin {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function getProxyAdmin(address proxy) external view returns (address) {
        (bool ok, bytes memory res) =
            proxy.staticcall(abi.encodeCall(Proxy.admin, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function getProxyImplementation(address proxy)
        external
        view
        returns (address)
    {
        (bool ok, bytes memory res) = 
            proxy.staticcall(abi.encodeCall(Proxy.implementation, ()));
        require(ok, "call failed");
        return abi.decode(res, (address));
    }

    function changeProxyAdmin(address payable proxy, address admin)
        external
        onlyOwner
    {
        Proxy(proxy).changAdmin(admin);
    }

    function upgrade(address payable proxy, address implementation)
        external
        onlyOwner
    {
        Proxy(proxy).upgradeTo(implementation);
    }
}