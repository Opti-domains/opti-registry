// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IDomain.sol";
import "./lib/DNSEncoder.sol";
import { ClonesWithImmutableArgs } from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";

/// @title DomainImplementation
/// @notice Implementation contract for domain management with immutable args
/// @dev Used as the base contract for cloneable proxies
abstract contract DomainImplementation is IDomain {
    using ClonesWithImmutableArgs for address;

    // Immutable args offsets
    uint256 private constant IMPLEMENTATION_OFFSET = 0;
    uint256 private constant PARENT_OFFSET = 20;
    uint256 private constant LABEL_LENGTH_OFFSET = 40;
    uint256 private constant LABEL_OFFSET = 42;

    address public owner;
    mapping(string => address) public subdomains;
    string[] private subdomainNames;

    error Unauthorized();
    error InvalidLabel();
    error SubdomainAlreadyExists();
    error InvalidParent();
    error SubdomainNotFound();

    mapping(address => bool) public authorizedDelegates;
    bool public subdomainOwnerDelegation;

    /// @notice Virtual function to check if caller is authorized as parent
    /// @return bool True if caller is authorized
    function isAuthorized() internal view virtual returns (bool) {
        bool isParentOwnerDelegated = false;
        address parentAddr = parent();
        if (parentAddr != address(0)) {
            isParentOwnerDelegated = DomainImplementation(parentAddr).subdomainOwnerDelegation() && owner == msg.sender;
        }

        return msg.sender == parentAddr || authorizedDelegates[msg.sender] || isParentOwnerDelegated;
    }

    modifier onlyAuthorized() {
        if (!isAuthorized()) {
            revert Unauthorized();
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    /// @notice Sets the owner of the domain
    /// @param _owner New owner address
    function setOwner(address _owner) external onlyAuthorized {
        emit OwnershipTransferred(owner, _owner);
        owner = _owner;
    }

    /// @notice Adds a new authorized delegate
    /// @param delegate Address to authorize
    function addAuthorizedDelegate(address delegate, bool authorized) external onlyAuthorized {
        authorizedDelegates[delegate] = authorized;
        emit DelegateAuthorized(delegate, authorized);
    }

    /// @notice Sets whether owner delegation is enabled for subdomains
    /// @param enabled Whether to enable owner delegation
    function setSubdomainOwnerDelegation(bool enabled) external onlyAuthorized {
        subdomainOwnerDelegation = enabled;
    }

    /// @notice Registers a new subdomain
    /// @param label The label for the subdomain
    /// @param subdomainOwner The owner of the new subdomain
    function registerSubdomain(string calldata label, address subdomainOwner)
        external
        onlyAuthorized
        returns (address)
    {
        bytes memory labelBytes = bytes(label);
        if (!DNSEncoder.isValidLabel(labelBytes)) revert InvalidLabel();
        if (subdomains[label] != address(0)) revert SubdomainAlreadyExists();

        // Create immutable args for the new subdomain
        bytes memory immutableArgs = abi.encodePacked(
            implementation(), // implementation address (20 bytes)
            address(this), // parent address (20 bytes)
            uint16(labelBytes.length), // label length (2 bytes)
            labelBytes // label (dynamic)
        );

        // Deploy new subdomain using implementation contract
        address subdomain = implementation().clone(immutableArgs);

        // Record the subdomain
        subdomains[label] = subdomain;
        subdomainNames.push(label);

        // Set the owner
        DomainImplementation(subdomain).setOwner(subdomainOwner);

        emit SubdomainRecorded(label, subdomain);
        return subdomain;
    }

    /// @notice Call a subdomain recursively with encoded DNS name and calldata
    /// @param reverseDnsEncoded The reverse DNS encoded name of the subdomain path
    /// @param data The calldata to pass to the final subdomain
    /// @return bytes The return data from the call
    function callSubdomain(bytes calldata reverseDnsEncoded, bytes calldata data)
        external
        onlyAuthorized
        returns (bytes memory)
    {
        // If no more labels, execute the call on this contract
        if (reverseDnsEncoded.length == 1 && reverseDnsEncoded[0] == 0) {
            (bool success, bytes memory returnData) = address(this).call(data);
            require(success, "Call failed");
            return returnData;
        }

        // Get the first label length
        uint8 labelLength = uint8(reverseDnsEncoded[0]);

        // Extract the label
        string memory currentLabel = string(reverseDnsEncoded[1:labelLength + 1]);

        // Get the subdomain address
        address subdomainAddr = subdomains[currentLabel];
        if (subdomainAddr == address(0)) revert SubdomainNotFound();

        // Get remaining encoded name
        bytes calldata remainingLabels = reverseDnsEncoded[labelLength + 1:];

        // Recursively call the subdomain
        return DomainImplementation(subdomainAddr).callSubdomain(remainingLabels, data);
    }

    /// @notice Gets the implementation contract address
    function implementation() public pure returns (address) {
        return _getArgAddress(IMPLEMENTATION_OFFSET);
    }

    /// @notice Gets the parent domain address
    function parent() public pure returns (address) {
        return _getArgAddress(PARENT_OFFSET);
    }

    /// @notice Gets the label of this domain
    function label() public pure returns (string memory) {
        uint16 labelLength = _getArgUint16(LABEL_LENGTH_OFFSET);
        bytes memory labelBytes = _getArgBytes(LABEL_OFFSET, labelLength);
        return string(labelBytes);
    }

    /// @notice Gets the full name as array of labels
    function name() public view returns (string[] memory) {
        return DNSEncoder.decodeName(dnsEncoded());
    }

    /// @notice Gets the full DNS encoded name by traversing to root
    function dnsEncoded() public view returns (bytes memory) {
        // Get parent's encoded name first
        bytes memory parentEncoded;
        address parentAddr = parent();

        if (parentAddr != address(0)) {
            // Recursively get parent's encoded name
            parentEncoded = DomainImplementation(parentAddr).dnsEncoded();
        } else {
            // At root, just return null terminator
            return abi.encodePacked(bytes1(0));
        }

        // Get this domain's label
        string memory domainLabel = label();
        bytes memory labelBytes = bytes(domainLabel);

        // Combine this label with parent's encoded name
        return abi.encodePacked(bytes1(uint8(labelBytes.length)), labelBytes, parentEncoded);
    }

    /// @notice Gets all subdomain names
    function getSubdomainNames() external view returns (string[] memory) {
        return subdomainNames;
    }

    // Internal helper functions for reading immutable args
    function _getArgAddress(uint256 offset) internal pure returns (address) {
        address arg;
        assembly {
            arg := shr(0x60, calldataload(offset))
        }
        return arg;
    }

    function _getArgUint16(uint256 offset) internal pure returns (uint16) {
        uint16 arg;
        assembly {
            arg := shr(0xf0, calldataload(offset))
        }
        return arg;
    }

    function _getArgBytes(uint256 offset, uint256 length) internal pure returns (bytes memory) {
        bytes memory arg = new bytes(length);
        assembly {
            calldatacopy(add(arg, 0x20), offset, length)
        }
        return arg;
    }
}
