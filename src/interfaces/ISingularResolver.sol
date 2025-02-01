// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISingularResolver {
    event AddrChanged(bytes32 indexed node, address addr);
    event TextChanged(bytes32 indexed node, string indexed key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes contenthash);
    event DNSRecordChanged(bytes32 indexed node, bytes name, uint16 resource, bytes record);
    event DNSZonehashChanged(bytes32 indexed node, bytes zonehash);

    function setAddr(address addr, bytes calldata dnsEncoded) external;
    function addr(bytes calldata dnsEncoded) external view returns (address);

    function setText(string calldata key, string calldata value, bytes calldata dnsEncoded) external;
    function text(bytes calldata dnsEncoded, string calldata key) external view returns (string memory);

    function setContenthash(bytes calldata hash, bytes calldata dnsEncoded) external;
    function contenthash(bytes calldata dnsEncoded) external view returns (bytes memory);
}
