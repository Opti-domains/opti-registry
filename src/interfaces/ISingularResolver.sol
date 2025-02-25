// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISingularResolver {
    event AddressChanged(bytes32 indexed node, uint256 cointype, bytes addr);
    event AddrChanged(bytes32 indexed node, address addr);
    event TextChanged(bytes32 indexed node, string indexed key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes contenthash);
    event DataChanged(bytes32 indexed node, string indexed key, bytes value);

    function setAddr(bytes calldata dnsEncoded, address addr) external;
    function addr(bytes calldata dnsEncoded) external view returns (address payable);
    function setAddr(bytes calldata dnsEncoded, uint256 coinType, bytes memory addr) external;
    function addr(bytes calldata dnsEncoded, uint256 coinType) external view returns (bytes memory);

    function setText(bytes calldata dnsEncoded, string calldata key, string calldata value) external;
    function text(bytes calldata dnsEncoded, string calldata key) external view returns (string memory);

    function setData(bytes calldata dnsEncoded, string calldata key, bytes calldata value) external;
    function data(bytes calldata dnsEncoded, string calldata key) external view returns (bytes memory);

    function setContenthash(bytes calldata dnsEncoded, bytes calldata hash) external;
    function contenthash(bytes calldata dnsEncoded) external view returns (bytes memory);
}
