// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ISingularResolverAuthorizer.sol";

interface ISingularResolver {
    event AddrChanged(bytes32 indexed node, address addr);
    event TextChanged(bytes32 indexed node, string indexed key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes contenthash);
    event DNSRecordChanged(bytes32 indexed node, bytes name, uint16 resource, bytes record);
    event DNSZonehashChanged(bytes32 indexed node, bytes zonehash);

    function setAddr(address addr, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer) external;
    function addr(bytes calldata dnsEncoded) external view returns (address);

    function setText(
        string calldata key,
        string calldata value,
        bytes calldata dnsEncoded,
        ISingularResolverAuthorizer authorizer
    ) external;
    function text(bytes calldata dnsEncoded, string calldata key) external view returns (string memory);

    function setContenthash(bytes calldata hash, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer)
        external;
    function contenthash(bytes calldata dnsEncoded) external view returns (bytes memory);

    function setDNSRecord(
        bytes calldata name,
        uint16 resource,
        bytes calldata record,
        bytes calldata dnsEncoded,
        ISingularResolverAuthorizer authorizer
    ) external;
    function dnsRecord(bytes calldata dnsEncoded, bytes calldata name, uint16 resource)
        external
        view
        returns (bytes memory);

    function setDNSZonehash(bytes calldata hash, bytes calldata dnsEncoded, ISingularResolverAuthorizer authorizer)
        external;
    function dnsZonehash(bytes calldata dnsEncoded) external view returns (bytes memory);
}
