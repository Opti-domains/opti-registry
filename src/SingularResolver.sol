// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IResolver.sol";
import "./interfaces/ISingularResolverAuthorizer.sol";

/// @title SingularResolver
/// @notice A resolver contract that stores and manages various DNS-related records
/// @dev Implements the IResolver interface with authorization checks
contract SingularResolver is IResolver {
    mapping(address => mapping(bytes32 => address)) private addresses;
    mapping(address => mapping(bytes32 => mapping(string => string))) private texts;
    mapping(address => mapping(bytes32 => bytes)) private contenthashes;
    mapping(address => mapping(bytes32 => mapping(bytes => mapping(uint16 => bytes)))) private dnsRecords;
    mapping(address => mapping(bytes32 => bytes)) private zonehashes;

    /// @notice Ensures that only authorized addresses can modify records
    /// @param authorizer The authorizer contract to check permissions
    /// @param node The node being modified
    modifier onlyAuthorized(ISingularResolverAuthorizer authorizer, bytes32 node) {
        require(authorizer.isResolverAuthorized(node, msg.sender, msg.data), "SingularResolver: Not authorized");
        _;
    }

    /// @notice Sets the address associated with a node
    /// @param authorizer The authorizer contract
    /// @param node The node to update
    /// @param addr The address to set
    function setAddr(ISingularResolverAuthorizer authorizer, bytes32 node, address addr)
        external
        onlyAuthorized(authorizer, node)
    {
        addresses[address(authorizer)][node] = addr;
        emit AddrChanged(node, addr);
    }

    function addr(bytes32 node) external view override returns (address) {
        return addresses[msg.sender][node];
    }

    function setText(ISingularResolverAuthorizer authorizer, bytes32 node, string calldata key, string calldata value)
        external
        onlyAuthorized(authorizer, node)
    {
        texts[address(authorizer)][node][key] = value;
        emit TextChanged(node, key, value);
    }

    function text(bytes32 node, string calldata key) external view override returns (string memory) {
        return texts[msg.sender][node][key];
    }

    function setContenthash(ISingularResolverAuthorizer authorizer, bytes32 node, bytes calldata hash)
        external
        onlyAuthorized(authorizer, node)
    {
        contenthashes[address(authorizer)][node] = hash;
        emit ContenthashChanged(node, hash);
    }

    function contenthash(bytes32 node) external view override returns (bytes memory) {
        return contenthashes[msg.sender][node];
    }

    function setDNSRecord(
        ISingularResolverAuthorizer authorizer,
        bytes32 node,
        bytes calldata name,
        uint16 resource,
        bytes calldata record
    ) external onlyAuthorized(authorizer, node) {
        dnsRecords[address(authorizer)][node][name][resource] = record;
        emit DNSRecordChanged(node, name, resource, record);
    }

    function dnsRecord(bytes32 node, bytes calldata name, uint16 resource)
        external
        view
        override
        returns (bytes memory)
    {
        return dnsRecords[msg.sender][node][name][resource];
    }

    function setDNSZonehash(ISingularResolverAuthorizer authorizer, bytes32 node, bytes calldata hash)
        external
        onlyAuthorized(authorizer, node)
    {
        zonehashes[address(authorizer)][node] = hash;
        emit DNSZonehashChanged(node, hash);
    }

    function dnsZonehash(bytes32 node) external view override returns (bytes memory) {
        return zonehashes[msg.sender][node];
    }
}
