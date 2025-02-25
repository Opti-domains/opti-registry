// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IDomain.sol";
import "./lib/DNSEncoder.sol";
import { ClonesWithImmutableArgs } from "clones-with-immutable-args/ClonesWithImmutableArgs.sol";
import { Clone } from "clones-with-immutable-args/Clone.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @title DomainImplementation
/// @notice Implementation contract for domain management with immutable args
/// @dev Used as the base contract for cloneable proxies
contract DomainImplementation is IDomain, Multicall, Clone {
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
    error SubdomainOwnerDelegationPermanent();

    mapping(address => bool) public authorizedDelegates;
    bool public subdomainOwnerDelegation;
    bool public subdomainOwnerDelegationPermanent;

    /// @notice Check if an address is authorized to manage this domain
    /// @param addr The address to check authorization for
    /// @return bool True if the address is authorized
    function isAuthorized(address addr) public view virtual returns (bool) {
        bool isParentOwnerDelegated = false;
        address parentAddr = parent();

        if (addr == address(0)) return false;

        if (parentAddr != address(0)) {
            isParentOwnerDelegated = DomainImplementation(parentAddr).subdomainOwnerDelegation();
        } else {
            return authorizedDelegates[addr];
        }

        if (isParentOwnerDelegated && owner != address(0)) {
            return owner == addr || authorizedDelegates[addr];
        }

        return addr == parentAddr || authorizedDelegates[addr] || DomainImplementation(parentAddr).isAuthorized(addr);
    }

    modifier onlyAuthorized() {
        if (!isAuthorized(msg.sender)) {
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
    function setOwner(address _owner) external virtual onlyAuthorized {
        emit OwnershipTransferred(owner, _owner);
        owner = _owner;
    }

    /// @notice Adds a new authorized delegate
    /// @param delegate Address to authorize
    function addAuthorizedDelegate(address delegate, bool authorized) external virtual onlyAuthorized {
        authorizedDelegates[delegate] = authorized;
        emit DelegateAuthorized(delegate, authorized);
    }

    /// @notice Sets whether owner delegation is enabled for subdomains
    /// @param enabled Whether to enable owner delegation
    function setSubdomainOwnerDelegation(bool enabled, bool permanent) external virtual onlyAuthorized {
        if (subdomainOwnerDelegationPermanent && !enabled) {
            revert SubdomainOwnerDelegationPermanent();
        }

        if (!enabled && permanent) {
            revert SubdomainOwnerDelegationPermanent();
        }

        subdomainOwnerDelegation = enabled;
        subdomainOwnerDelegationPermanent = permanent;
    }

    /// @notice Registers a new subdomain
    /// @param label The label for the subdomain
    /// @param subdomainOwner The owner of the new subdomain
    function registerSubdomain(string calldata label, address subdomainOwner)
        external
        virtual
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
        virtual
        onlyAuthorized
        returns (bytes memory)
    {
        address target = getNestedAddress(reverseDnsEncoded);
        (bool success, bytes memory returnData) = target.call(data);
        require(success, "Call failed");
        return returnData;
    }

    /// @notice Gets the implementation contract address for subdomains
    function implementation() public view virtual returns (address) {
        return _getArgAddress(IMPLEMENTATION_OFFSET);
    }

    /// @notice Gets the parent domain address
    function parent() public view virtual returns (address) {
        return _getArgAddress(PARENT_OFFSET);
    }

    /// @notice Gets the label of this domain
    function label() public view virtual returns (string memory) {
        uint16 labelLength = _getArgUint16(LABEL_LENGTH_OFFSET);
        bytes memory labelBytes = _getArgBytes(LABEL_OFFSET, labelLength);
        return string(labelBytes);
    }

    /// @notice Gets the full name as array of labels
    function name() public view virtual returns (string[] memory) {
        return DNSEncoder.decodeName(dnsEncoded());
    }

    /// @notice Gets the full DNS encoded name by traversing to root
    function dnsEncoded() public view virtual returns (bytes memory) {
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

    /// @notice Gets the total number of subdomain names
    function getSubdomainCount() public view virtual returns (uint256) {
        return subdomainNames.length;
    }

    /// @notice Gets a slice of subdomain names
    /// @param start The starting index
    /// @param length The number of names to return
    function getSubdomainNames(uint256 start, uint256 length) public view virtual returns (string[] memory) {
        require(start + length <= subdomainNames.length, "Invalid range");
        string[] memory slice = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            slice[i] = subdomainNames[start + i];
        }
        return slice;
    }

    /// @notice Gets a list of all subdomain names
    function getSubdomainNames() external view virtual returns (string[] memory) {
        return subdomainNames;
    }

    /// @notice Gets the address of a nested subdomain using reversed DNS encoded name
    /// @param reverseDnsEncoded The reversed DNS encoded name
    /// @return The address of the target domain
    function getNestedAddress(bytes calldata reverseDnsEncoded) public view returns (address) {
        // If no more labels, return this contract
        if (reverseDnsEncoded.length == 1 && reverseDnsEncoded[0] == 0) {
            return address(this);
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

        // Recursively get the nested address
        return DomainImplementation(subdomainAddr).getNestedAddress(remainingLabels);
    }

    /// @notice Gets the resolver from parent or self
    function resolver() public view virtual returns (address) {
        return IDomain(parent()).resolver();
    }

    function _getArgUint16(uint256 offset) internal pure returns (uint16) {
        uint16 arg;
        uint256 baseOffset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf0, calldataload(add(baseOffset, offset)))
        }
        return arg;
    }

    function _getArgBytes(uint256 offset, uint256 length) internal pure returns (bytes memory) {
        bytes memory arg = new bytes(length);
        uint256 baseOffset = _getImmutableArgsOffset();
        assembly {
            calldatacopy(add(arg, 0x20), add(baseOffset, offset), length)
        }
        return arg;
    }
}
