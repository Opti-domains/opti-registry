// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IResolver {
    event AddrChanged(bytes32 indexed node, address addr);
    event TextChanged(bytes32 indexed node, string indexed key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes contenthash);
    event DNSRecordChanged(bytes32 indexed node, bytes name, uint16 resource, bytes record);
    event DNSZonehashChanged(bytes32 indexed node, bytes zonehash);

    function addr(bytes32 node) external view returns (address);

    function text(bytes32 node, string calldata key) external view returns (string memory);

    function contenthash(bytes32 node) external view returns (bytes memory);

    function dnsRecord(bytes32 node, bytes calldata name, uint16 resource) external view returns (bytes memory);

    function dnsZonehash(bytes32 node) external view returns (bytes memory);
}
