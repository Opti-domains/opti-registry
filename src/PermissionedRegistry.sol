// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/IDomain.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";

/// @title PermissionedRegistry
/// @notice A registry contract that can be delegated to register subdomains with EIP-712 signature verification
contract PermissionedRegistry is EIP712, Multicall {
    // EIP-712 type hashes
    bytes32 public constant REGISTER_TYPEHASH =
        keccak256("Register(address domain,string label,address owner,uint256 deadline,bytes32 nonce)");

    // Mapping to track used nonces
    mapping(bytes32 => bool) public usedNonces;

    error SignatureExpired();
    error InvalidSignature();
    error NonceAlreadyUsed();
    error RegistrationFailed();

    event SubdomainRegistered(
        address indexed domain, string label, address indexed owner, uint256 deadline, bytes32 nonce
    );

    constructor() EIP712("OptiPermissionedRegistry", "1.0.0") { }

    /// @notice Register a subdomain with EIP-712 signature verification
    /// @param domain The domain contract address under which to register
    /// @param label The subdomain label to register
    /// @param owner The owner of the new subdomain
    /// @param deadline The timestamp at which the signature expires
    /// @param nonce A unique nonce for this registration
    /// @param signature The signature authorizing this registration
    /// @return The address of the newly registered subdomain
    function register(
        address domain,
        string calldata label,
        address owner,
        uint256 deadline,
        bytes32 nonce,
        bytes calldata signature
    ) external returns (address) {
        // Verify signature and check expiration/nonce
        if (!verifySignature(domain, label, owner, deadline, nonce, signature)) {
            revert InvalidSignature();
        }

        // Mark nonce as used (must be done after verification)
        usedNonces[nonce] = true;

        // Register the subdomain
        address subdomain = IDomain(domain).registerSubdomain(label, owner);
        if (subdomain == address(0)) revert RegistrationFailed();

        emit SubdomainRegistered(domain, label, owner, deadline, nonce);

        return subdomain;
    }

    /// @notice Verify if a signature is valid for a registration
    /// @param domain The domain contract address
    /// @param label The subdomain label
    /// @param owner The intended owner
    /// @param deadline The expiration timestamp
    /// @param nonce The unique nonce
    /// @param signature The signature to verify
    /// @return bool True if the signature is valid
    function verifySignature(
        address domain,
        string calldata label,
        address owner,
        uint256 deadline,
        bytes32 nonce,
        bytes calldata signature
    ) public view returns (bool) {
        // Check expiration
        if (block.timestamp > deadline) return false;

        // Check if nonce has been used
        if (usedNonces[nonce]) return false;

        // Get domain owner
        address domainOwner = IDomain(domain).owner();

        // Verify signature using EIP-712
        bytes32 structHash =
            keccak256(abi.encode(REGISTER_TYPEHASH, domain, keccak256(bytes(label)), owner, deadline, nonce));
        bytes32 hash = _hashTypedDataV4(structHash);

        // Verify using SignatureChecker
        return SignatureChecker.isValidSignatureNow(domainOwner, hash, signature);
    }

    /// @notice Get the EIP-712 domain separator
    function getDomainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /// @notice Get the struct hash for signing
    /// @param domain The domain contract address
    /// @param label The subdomain label
    /// @param owner The intended owner
    /// @param deadline The expiration timestamp
    /// @param nonce The unique nonce
    /// @return The struct hash to sign
    function getStructHash(address domain, string calldata label, address owner, uint256 deadline, bytes32 nonce)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(REGISTER_TYPEHASH, domain, keccak256(bytes(label)), owner, deadline, nonce));
    }
}
