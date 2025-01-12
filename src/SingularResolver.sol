// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/ISingularResolver.sol";
import "./interfaces/ISingularResolverAuthorizer.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @title SingularResolver
/// @notice A resolver contract that stores and manages various DNS-related records
/// @dev Implements the IResolver interface with authorization checks
contract SingularResolver is ISingularResolver, Multicall {
    error NotAuthorized();

    /// @notice Mapping of authorizer address to domain hash to resolved address
    mapping(address => mapping(bytes32 => address)) private addresses;
    /// @notice Mapping of authorizer address to domain hash to key to text value
    mapping(address => mapping(bytes32 => mapping(string => string))) private texts;
    /// @notice Mapping of authorizer address to domain hash to content hash
    mapping(address => mapping(bytes32 => bytes)) private contenthashes;
    /// @notice Mapping of authorizer address to domain hash to DNS name to resource type to record
    mapping(address => mapping(bytes32 => mapping(bytes => mapping(uint16 => bytes)))) private dnsRecords;
    /// @notice Mapping of authorizer address to domain hash to zone hash
    mapping(address => mapping(bytes32 => bytes)) private zonehashes;

    /// @notice Modifier to check if caller is authorized by the authorizer contract
    /// @param authorizer The authorizer contract to check against
    /// @param dnsEncoded The DNS encoded name to check authorization for
    modifier onlyAuthorized(ISingularResolverAuthorizer authorizer, bytes calldata dnsEncoded) {
        if (!authorizer.isResolverAuthorized(dnsEncoded, msg.sender, msg.data)) {
            revert NotAuthorized();
        }
        _;
    }

    /// @notice Sets the address record for a domain
    /// @param addr The address to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param authorizer The authorizer contract to check permissions against
    function setAddr(address addr, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer)
        external
        onlyAuthorized(authorizer, dnsEncoded)
    {
        addresses[address(authorizer)][keccak256(dnsEncoded)] = addr;
        emit AddrChanged(keccak256(dnsEncoded), addr);
    }

    /// @notice Gets the address record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The resolved address
    function addr(bytes calldata dnsEncoded) external view override returns (address) {
        return addresses[msg.sender][keccak256(dnsEncoded)];
    }

    /// @notice Sets a text record for a domain
    /// @param key The key for the text record
    /// @param value The value to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param authorizer The authorizer contract to check permissions against
    function setText(
        string calldata key,
        string calldata value,
        bytes calldata dnsEncoded,
        ISingularResolverAuthorizer authorizer
    ) external onlyAuthorized(authorizer, dnsEncoded) {
        texts[address(authorizer)][keccak256(dnsEncoded)][key] = value;
        emit TextChanged(keccak256(dnsEncoded), key, value);
    }

    /// @notice Gets a text record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param key The key for the text record
    /// @return The text value
    function text(bytes calldata dnsEncoded, string calldata key) external view override returns (string memory) {
        return texts[msg.sender][keccak256(dnsEncoded)][key];
    }

    /// @notice Sets the content hash for a domain
    /// @param hash The content hash to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param authorizer The authorizer contract to check permissions against
    function setContenthash(bytes calldata hash, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer)
        external
        onlyAuthorized(authorizer, dnsEncoded)
    {
        contenthashes[address(authorizer)][keccak256(dnsEncoded)] = hash;
        emit ContenthashChanged(keccak256(dnsEncoded), hash);
    }

    /// @notice Gets the content hash for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The content hash
    function contenthash(bytes calldata dnsEncoded) external view override returns (bytes memory) {
        return contenthashes[msg.sender][keccak256(dnsEncoded)];
    }

    /// @notice Sets a DNS record for a domain
    /// @param name The DNS record name
    /// @param resource The DNS record type
    /// @param record The DNS record data
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param authorizer The authorizer contract to check permissions against
    function setDNSRecord(
        bytes calldata name,
        uint16 resource,
        bytes calldata record,
        bytes calldata dnsEncoded,
        ISingularResolverAuthorizer authorizer
    ) external onlyAuthorized(authorizer, dnsEncoded) {
        dnsRecords[address(authorizer)][keccak256(dnsEncoded)][name][resource] = record;
        emit DNSRecordChanged(keccak256(dnsEncoded), name, resource, record);
    }

    /// @notice Gets a DNS record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param name The DNS record name
    /// @param resource The DNS record type
    /// @return The DNS record data
    function dnsRecord(bytes calldata dnsEncoded, bytes calldata name, uint16 resource)
        external
        view
        override
        returns (bytes memory)
    {
        return dnsRecords[msg.sender][keccak256(dnsEncoded)][name][resource];
    }

    /// @notice Sets the DNS zone hash for a domain
    /// @param hash The zone hash to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param authorizer The authorizer contract to check permissions against
    function setDNSZonehash(bytes calldata hash, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer)
        external
        onlyAuthorized(authorizer, dnsEncoded)
    {
        zonehashes[address(authorizer)][keccak256(dnsEncoded)] = hash;
        emit DNSZonehashChanged(keccak256(dnsEncoded), hash);
    }

    /// @notice Gets the DNS zone hash for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The zone hash
    function dnsZonehash(bytes calldata dnsEncoded) external view override returns (bytes memory) {
        return zonehashes[msg.sender][keccak256(dnsEncoded)];
    }
}
