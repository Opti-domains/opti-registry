// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IDomainRegistry.sol";
import "./lib/ClonesWithImmutableArgs.sol";
import "./lib/DNSEncoder.sol";
import "./DomainImplementation.sol";

/// @title DomainRegistry
/// @notice Registry for managing domain creation and proxy deployment
contract DomainRegistry is IDomainRegistry {
    using ClonesWithImmutableArgs for address;

    address public immutable implementation;
    mapping(string => address) public domains;
    mapping(string => string[]) public subdomains;

    error DomainExists();
    error InvalidDomain();
    error InvalidParentDomain();

    constructor(address _implementation) {
        implementation = _implementation;
    }

    /// @notice Creates a new domain using the minimal proxy pattern with immutable args
    /// @param owner Address that will own the domain
    /// @param name Domain name (e.g., "example.com")
    /// @param parentName Parent domain name in DNS wire format (empty for root domains)
    function createDomain(
        address owner,
        string memory name,
        bytes memory parentName
    ) external returns (address) {
        if (domains[name] != address(0)) revert DomainExists();
        if (parentName.length > 0) {
            if (!DNSEncoder.isValidDomain(parentName)) revert InvalidDomain();
            string memory parentString = string(
                DNSEncoder.decodeName(parentName)[0]
            );
            if (domains[parentString] == address(0))
                revert InvalidParentDomain();
        }

        // Encode name in DNS wire format
        string[] memory labels = new string[](1);
        labels[0] = name;
        bytes memory encodedName = DNSEncoder.encodeName(labels);

        // Encode initialization data as immutable args
        bytes memory immutableArgs = abi.encodePacked(
            address(this), // registry
            uint16(encodedName.length),
            encodedName,
            uint16(parentName.length),
            parentName
        );

        // Create clone with immutable args
        address clone = implementation.clone(immutableArgs);
        domains[name] = clone;

        // Initialize the domain with its owner
        DomainImplementation(clone).initialize(owner);

        // Record subdomain relationship
        if (parentName.length > 0) {
            string memory parentString = string(
                DNSEncoder.decodeName(parentName)[0]
            );
            subdomains[parentString].push(name);
        }

        emit DomainCreated(
            clone,
            owner,
            name,
            string(DNSEncoder.decodeName(parentName)[0])
        );
        return clone;
    }

    /// @notice Gets all subdomains of a domain
    /// @param name The domain name to query
    /// @return Array of subdomain names
    function getSubdomains(
        string memory name
    ) external view returns (string[] memory) {
        return subdomains[name];
    }
}
