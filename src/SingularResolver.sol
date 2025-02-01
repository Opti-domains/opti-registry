// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/ISingularResolver.sol";
import "./interfaces/IDomain.sol";
import "./lib/DNSEncoder.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @title SingularResolver
/// @notice A resolver contract that stores and manages various DNS-related records
/// @dev Implements the IResolver interface with authorization checks
contract SingularResolver is ISingularResolver, Multicall {
    error NotAuthorized();

    IDomain public immutable root;

    /// @notice Mapping of domain hash to resolved address
    mapping(bytes32 => address) private addresses;
    /// @notice Mapping of domain hash to key to text value
    mapping(bytes32 => mapping(string => string)) private texts;
    /// @notice Mapping of domain hash to content hash
    mapping(bytes32 => bytes) private contenthashes;
    /// @notice Mapping of domain hash to DNS name to resource type to record
    mapping(bytes32 => mapping(bytes => mapping(uint16 => bytes))) private dnsRecords;
    /// @notice Mapping of domain hash to zone hash
    mapping(bytes32 => bytes) private zonehashes;

    constructor(address _root) {
        root = IDomain(_root);
    }

    /// @notice Modifier to check if caller is authorized for the domain
    /// @param dnsEncoded The DNS encoded name to check authorization for
    modifier onlyAuthorized(bytes calldata dnsEncoded) {
        bytes memory reversedName = DNSEncoder.reverseDnsEncoded(dnsEncoded);
        address domainAddr = root.getNestedAddress(reversedName);
        if (!IDomain(domainAddr).isAuthorized(msg.sender)) {
            revert NotAuthorized();
        }
        _;
    }

    /// @notice Sets the address record for a domain
    /// @param addr The address to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    function setAddr(address addr, bytes calldata dnsEncoded) external onlyAuthorized(dnsEncoded) {
        bytes32 node = keccak256(dnsEncoded);
        addresses[node] = addr;
        emit AddrChanged(node, addr);
    }

    /// @notice Gets the address record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The resolved address
    function addr(bytes calldata dnsEncoded) external view returns (address) {
        return addresses[keccak256(dnsEncoded)];
    }

    /// @notice Sets a text record for a domain
    /// @param key The key for the text record
    /// @param value The value to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    function setText(string calldata key, string calldata value, bytes calldata dnsEncoded)
        external
        onlyAuthorized(dnsEncoded)
    {
        bytes32 node = keccak256(dnsEncoded);
        texts[node][key] = value;
        emit TextChanged(node, key, value);
    }

    /// @notice Gets a text record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param key The key for the text record
    /// @return The text value
    function text(bytes calldata dnsEncoded, string calldata key) external view returns (string memory) {
        return texts[keccak256(dnsEncoded)][key];
    }

    /// @notice Sets the content hash for a domain
    /// @param hash The content hash to set
    /// @param dnsEncoded The DNS encoded name to set the record for
    function setContenthash(bytes calldata hash, bytes calldata dnsEncoded) external onlyAuthorized(dnsEncoded) {
        bytes32 node = keccak256(dnsEncoded);
        contenthashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /// @notice Gets the content hash for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The content hash
    function contenthash(bytes calldata dnsEncoded) external view returns (bytes memory) {
        return contenthashes[keccak256(dnsEncoded)];
    }
}
