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

    /// @notice Mapping of domain hash to resolved address
    mapping(bytes32 => mapping(uint256 => bytes)) private addresses;
    /// @notice Mapping of domain hash to key to text value
    mapping(bytes32 => mapping(string => string)) private texts;
    /// @notice Mapping of domain hash to key to data value
    mapping(bytes32 => mapping(string => bytes)) private dataRecords;
    /// @notice Mapping of domain hash to content hash
    mapping(bytes32 => bytes) private contenthashes;

    IDomain public immutable root;

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

    function bytesToAddress(bytes memory b) internal pure returns (address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns (bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }

    /// @notice Sets the address record for a domain with coin type
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param coinType The coin type to set the address for
    /// @param addr The address to set
    function setAddr(bytes calldata dnsEncoded, uint256 coinType, bytes memory addr)
        public
        onlyAuthorized(dnsEncoded)
    {
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);
        addresses[node][coinType] = addr;
        emit AddressChanged(node, coinType, addr);
        if (coinType == 60) {
            emit AddrChanged(node, bytesToAddress(addr));
        }
    }

    /// @notice Sets the address record for a domain (defaults to ETH)
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param addr The address to set
    function setAddr(bytes calldata dnsEncoded, address addr) public onlyAuthorized(dnsEncoded) {
        setAddr(dnsEncoded, 60, addressToBytes(addr));
    }

    /// @notice Gets the address record for a domain with coin type
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param coinType The coin type to get the address for
    /// @return The resolved address
    function addr(bytes calldata dnsEncoded, uint256 coinType) public view returns (bytes memory) {
        return addresses[DNSEncoder.dnsEncodedNamehash(dnsEncoded)][coinType];
    }

    /// @notice Gets the address record for a domain (defaults to ETH)
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The resolved address
    function addr(bytes calldata dnsEncoded) public view returns (address payable) {
        bytes memory a = addr(dnsEncoded, 60);
        if (a.length == 0) {
            return payable(address(0));
        }
        return bytesToAddress(a);
    }

    /// @notice Sets a text record for a domain
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param key The key for the text record
    /// @param value The value to set
    function setText(bytes calldata dnsEncoded, string calldata key, string calldata value)
        public
        onlyAuthorized(dnsEncoded)
    {
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);
        texts[node][key] = value;
        emit TextChanged(node, key, value);
    }

    /// @notice Gets a text record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param key The key for the text record
    /// @return The text value
    function text(bytes calldata dnsEncoded, string calldata key) public view returns (string memory) {
        return texts[DNSEncoder.dnsEncodedNamehash(dnsEncoded)][key];
    }

    /// @notice Sets a data record for a domain
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param key The key for the data record
    /// @param value The value to set
    function setData(bytes calldata dnsEncoded, string calldata key, bytes calldata value)
        public
        onlyAuthorized(dnsEncoded)
    {
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);
        dataRecords[node][key] = value;
        emit DataChanged(node, key, value);
    }

    /// @notice Gets a data record for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @param key The key for the data record
    /// @return The data value
    function data(bytes calldata dnsEncoded, string calldata key) public view returns (bytes memory) {
        return dataRecords[DNSEncoder.dnsEncodedNamehash(dnsEncoded)][key];
    }

    /// @notice Sets the content hash for a domain
    /// @param dnsEncoded The DNS encoded name to set the record for
    /// @param hash The content hash to set
    function setContenthash(bytes calldata dnsEncoded, bytes calldata hash) public onlyAuthorized(dnsEncoded) {
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);
        contenthashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /// @notice Gets the content hash for a domain
    /// @param dnsEncoded The DNS encoded name to get the record for
    /// @return The content hash
    function contenthash(bytes calldata dnsEncoded) public view returns (bytes memory) {
        return contenthashes[DNSEncoder.dnsEncodedNamehash(dnsEncoded)];
    }
}
