// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DomainImplementation.sol";
import { ClonesWithImmutableArgs } from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

/// @title DomainRoot
/// @notice Root domain implementation with owner-only authorization
contract DomainRoot is DomainImplementation {
    using ClonesWithImmutableArgs for address;

    error NotAuthorized();

    address public immutable baseImplementation;
    address public baseResolver;

    constructor(address _implementation, address _owner) {
        baseImplementation = _implementation;
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }

    /// @notice Set the base resolver address
    /// @param _resolver The new resolver address
    function setResolver(address _resolver) external {
        if (!isAuthorized(msg.sender)) revert NotAuthorized();
        baseResolver = _resolver;
    }

    /// @notice Override authorization to only allow owner
    /// @param addr The address to check authorization for
    /// @return bool True if the address is the owner
    function isAuthorized(address addr) public view virtual override returns (bool) {
        return addr == owner || super.isAuthorized(addr);
    }

    /// @notice Override parent to always return address(0)
    function parent() public pure virtual override returns (address) {
        return address(0);
    }

    /// @notice Override label to always return empty string
    function label() public pure virtual override returns (string memory) {
        return "";
    }

    /// @notice Override dnsEncoded to always return null terminator
    function dnsEncoded() public pure virtual override returns (bytes memory) {
        return abi.encodePacked(bytes1(0));
    }

    /// @notice Override name to always return empty array
    function name() public pure virtual override returns (string[] memory) {
        return new string[](0);
    }

    /// @notice Override resolver
    function resolver() public view virtual override returns (address) {
        return baseResolver;
    }

    /// @notice Override implementation
    function implementation() public view virtual override returns (address) {
        return baseImplementation;
    }
}
