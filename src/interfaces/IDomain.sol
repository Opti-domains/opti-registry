// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDomain {
    /// @notice Emitted when domain ownership is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice Emitted when a subdomain is recorded
    event SubdomainRecorded(string indexed name, address indexed proxyAddress);

    /// @notice Emitted when a delegate is authorized
    event DelegateAuthorized(address indexed delegate, bool authorized);

    /// @notice Sets the owner of the domain (only callable by parent)
    /// @param owner New owner address
    function setOwner(address owner) external;

    /// @notice Registers a new subdomain (only callable by owner)
    /// @param label The label for the subdomain
    /// @param subdomainOwner The owner of the new subdomain
    /// @return The address of the new subdomain contract
    function registerSubdomain(
        string calldata label,
        address subdomainOwner
    ) external returns (address);

    /// @notice Gets the current owner of the domain
    function owner() external view returns (address);

    /// @notice Gets the implementation contract address
    function implementation() external pure returns (address);

    /// @notice Gets the parent domain address
    function parent() external pure returns (address);

    /// @notice Gets the label of this domain
    function label() external pure returns (string memory);

    /// @notice Gets the full name as array of labels
    function name() external view returns (string[] memory);

    /// @notice Gets the full DNS encoded name
    function dnsEncoded() external view returns (bytes memory);

    /// @notice Gets all subdomain names
    function getSubdomainNames() external view returns (string[] memory);

    /// @notice Gets the proxy address for a subdomain
    /// @param name The subdomain name
    /// @return The proxy address of the subdomain
    function subdomains(string memory name) external view returns (address);
}
