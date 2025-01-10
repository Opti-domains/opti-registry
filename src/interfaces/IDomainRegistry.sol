// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDomainRegistry {
    event DomainCreated(
        address indexed domain,
        address indexed owner,
        string name,
        string parentName
    );

    function createDomain(
        address owner,
        string memory name,
        string memory parentName
    ) external returns (address);

    function getSubdomains(
        string memory name
    ) external view returns (string[] memory);
}
