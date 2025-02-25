// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDomain {
    /// @notice Emitted when domain ownership is transferred
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @notice Emitted when a subdomain is recorded
    event SubdomainRecorded(string indexed name, address indexed proxyAddress);

    /// @notice Emitted when a delegate is authorized
    event DelegateAuthorized(address indexed delegate, bool authorized);

    /// @notice Sets the owner of the domain (only callable by authorized)
    /// @param owner New owner address
    function setOwner(address owner) external;

    /// @notice Registers a new subdomain (only callable by authorized)
    /// @param label The label for the subdomain
    /// @param subdomainOwner The owner of the new subdomain
    /// @return The address of the new subdomain contract
    function registerSubdomain(string calldata label, address subdomainOwner) external returns (address);

    /// @notice Call a subdomain recursively with encoded DNS name and calldata
    /// @param reverseDnsEncoded The reverse DNS encoded name of the subdomain path
    /// @param data The calldata to pass to the final subdomain
    /// @return bytes The return data from the call
    function callSubdomain(bytes calldata reverseDnsEncoded, bytes calldata data) external returns (bytes memory);

    /// @notice Gets the current owner of the domain
    function owner() external view returns (address);

    /// @notice Gets the implementation contract address
    function implementation() external view returns (address);

    /// @notice Gets the parent domain address
    function parent() external view returns (address);

    /// @notice Gets the label of this domain
    function label() external view returns (string memory);

    /// @notice Gets the full name as array of labels
    function name() external view returns (string[] memory);

    /// @notice Gets the full DNS encoded name
    function dnsEncoded() external view returns (bytes memory);

    /// @notice Gets the total number of subdomain names
    function getSubdomainCount() external view returns (uint256);

    /// @notice Gets a slice of subdomain names
    /// @param start The starting index
    /// @param length The number of names to return
    function getSubdomainNames(uint256 start, uint256 length) external view returns (string[] memory);

    /// @notice Gets the proxy address for a subdomain
    /// @param name The subdomain name
    /// @return The proxy address of the subdomain
    function subdomains(string memory name) external view returns (address);

    /// @notice Gets the resolver from parent or self
    function resolver() external view returns (address);

    /// @notice Gets the address of a nested subdomain using reversed DNS encoded name
    /// @param reverseDnsEncoded The reversed DNS encoded name
    /// @return The address of the target domain
    function getNestedAddress(bytes calldata reverseDnsEncoded) external view returns (address);

    /// @notice Check if an address is authorized to manage this domain
    /// @param addr The address to check authorization for
    /// @return bool True if the address is authorized
    function isAuthorized(address addr) external view returns (bool);

    /// @notice Adds a new authorized delegate
    /// @param delegate Address to authorize
    /// @param authorized Whether to authorize or revoke
    function addAuthorizedDelegate(address delegate, bool authorized) external;

    /// @notice Sets whether owner delegation is enabled for subdomains
    /// @param enabled Whether to enable owner delegation
    function setSubdomainOwnerDelegation(bool enabled, bool permanent) external;

    /// @notice Gets whether an address is an authorized delegate
    function authorizedDelegates(address delegate) external view returns (bool);

    /// @notice Gets whether subdomain owner delegation is enabled
    function subdomainOwnerDelegation() external view returns (bool);
}
