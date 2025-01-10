// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDomain {
    event DomainInitialized(
        address indexed owner,
        string name,
        string parentName
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function initialize(address owner) external;

    function transferOwnership(address newOwner) external;

    function owner() external view returns (address);

    function name() external pure returns (string memory);

    function parentName() external pure returns (string memory);

    function registry() external pure returns (address);
}
