// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IDomain.sol";
import "./lib/DNSEncoder.sol";

/// @title DomainImplementation
/// @notice Implementation contract for domain management with immutable args
/// @dev Used as the base contract for cloneable proxies
contract DomainImplementation is IDomain {
    // Immutable args offsets
    uint256 private constant REGISTRY_OFFSET = 0;
    uint256 private constant NAME_LENGTH_OFFSET = 20;
    uint256 private constant NAME_OFFSET = 22;
    uint256 private constant PARENT_NAME_LENGTH_OFFSET = 0; // Dynamic, calculated from name length

    address public owner;
    bool private initialized;

    error Unauthorized();
    error AlreadyInitialized();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyRegistry() {
        if (msg.sender != registry()) revert Unauthorized();
        _;
    }

    /// @notice Initializes the domain with an owner
    /// @param _owner Initial owner of the domain
    function initialize(address _owner) external onlyRegistry {
        if (initialized) revert AlreadyInitialized();
        owner = _owner;
        initialized = true;
        emit DomainInitialized(_owner, name(), parentName());
    }

    /// @notice Gets the registry address from immutable args
    function registry() public pure returns (address) {
        return _getArgAddress(REGISTRY_OFFSET);
    }

    /// @notice Gets the domain name from immutable args
    function name() public pure returns (string memory) {
        uint16 nameLength = _getArgUint16(NAME_LENGTH_OFFSET);
        bytes memory nameBytes = _getArgBytes(NAME_OFFSET, nameLength);
        return string(nameBytes);
    }

    /// @notice Gets the parent domain name from immutable args
    function parentName() public pure returns (string memory) {
        uint16 nameLength = _getArgUint16(NAME_LENGTH_OFFSET);
        uint256 parentOffset = NAME_OFFSET + nameLength;
        uint16 parentLength = _getArgUint16(parentOffset);
        bytes memory parentBytes = _getArgBytes(parentOffset + 2, parentLength);
        return string(parentBytes);
    }

    /// @notice Transfers ownership of the domain
    /// @param newOwner Address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /// @dev Reads an address from immutable args at the given offset
    function _getArgAddress(uint256 offset) internal pure returns (address) {
        address arg;
        assembly {
            arg := shr(0x60, calldataload(offset))
        }
        return arg;
    }

    /// @dev Reads a uint16 from immutable args at the given offset
    function _getArgUint16(uint256 offset) internal pure returns (uint16) {
        uint16 arg;
        assembly {
            arg := shr(0xf0, calldataload(offset))
        }
        return arg;
    }

    /// @dev Reads bytes from immutable args at the given offset
    function _getArgBytes(
        uint256 offset,
        uint256 length
    ) internal pure returns (bytes memory) {
        bytes memory arg = new bytes(length);
        assembly {
            calldatacopy(add(arg, 0x20), offset, length)
        }
        return arg;
    }
}
