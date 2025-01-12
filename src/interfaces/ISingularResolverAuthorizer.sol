// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISingularResolverAuthorizer {
    /// @notice Checks if a caller is authorized to modify resolver records for a domain
    /// @param dnsEncoded The DNS encoded name of the domain
    /// @param caller The address attempting to modify records
    /// @param data The calldata of the modification attempt
    /// @return bool True if the caller is authorized
    function isResolverAuthorized(bytes calldata dnsEncoded, address caller, bytes calldata data)
        external
        view
        returns (bool);
}
