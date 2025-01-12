// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./DomainImplementation.sol";
import { ClonesWithImmutableArgs } from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

/// @title DomainRoot
/// @notice Root domain implementation with owner-only authorization
contract DomainRoot is DomainImplementation {
    using ClonesWithImmutableArgs for address;

    address baseResolver;

    constructor(address _implementation, address _owner, address _resolver) {
        // Set immutable args in storage since this is not a clone
        bytes memory immutableArgs = abi.encodePacked(
            _implementation, // implementation address (20 bytes)
            address(0), // parent address (20 bytes)
            uint16(0), // label length (2 bytes)
            bytes("") // empty label (0 bytes)
        );

        // Store immutable args
        assembly {
            let length := mload(immutableArgs)
            let data := add(immutableArgs, 0x20)
            sstore(0, mload(data))
            if gt(length, 0x20) { sstore(1, mload(add(data, 0x20))) }
        }

        owner = _owner;
        baseResolver = _resolver;
        emit OwnershipTransferred(address(0), _owner);
    }

    /// @notice Override authorization to only allow owner
    /// @param addr The address to check authorization for
    /// @return bool True if the address is the owner
    function isAuthorized(address addr) public view virtual override returns (bool) {
        return addr == owner;
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
}
