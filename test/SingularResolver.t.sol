// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";
import "../src/SingularResolver.sol";
import "../src/DomainRoot.sol";
import "../src/lib/DNSEncoder.sol";

contract SingularResolverTest is Test {
    SingularResolver public resolver;
    DomainRoot public root;
    address public implementation;
    address public owner;

    function setUp() public {
        implementation = address(new DomainImplementation());
        owner = address(this);

        root = new DomainRoot(implementation, owner);
        address subdomain = root.registerSubdomain("test", owner);
        root.setSubdomainOwnerDelegation(true, true);

        resolver = new SingularResolver(address(root));
        root.setResolver(address(resolver));

        DomainImplementation(subdomain).registerSubdomain("aaa", address(0x765));
    }

    function testSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        address addr = address(0xabc);
        bytes memory addrOther = bytes(abi.encodePacked(uint256(0x987)));
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);

        vm.prank(owner);
        resolver.setAddr(dnsEncoded, addr);
        vm.stopPrank();

        vm.prank(owner);
        resolver.setAddr(dnsEncoded, 1, addrOther);
        vm.stopPrank();

        assertEq(resolver.addr(dnsEncoded), addr);
        assertEq(resolver.addr(dnsEncoded, 1), addrOther);
    }

    function testSetText() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        string memory value = "value";
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);

        vm.prank(owner);
        resolver.setText(dnsEncoded, key, value);
        vm.stopPrank();

        assertEq(resolver.text(dnsEncoded, key), value);
    }

    function testSetData() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        bytes memory value = hex"1234";
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);

        vm.prank(owner);
        resolver.setData(dnsEncoded, key, value);
        vm.stopPrank();

        assertEq(resolver.data(dnsEncoded, key), value);
    }

    function testUnauthorizedSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        vm.prank(address(0x456));
        vm.expectRevert();
        resolver.setAddr(dnsEncoded, address(0xabc));
        vm.stopPrank();

        assertEq(resolver.addr(dnsEncoded), address(0));
    }

    function testUnauthorizedSetData() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        bytes memory value = hex"1234";

        vm.prank(address(0x456));
        vm.expectRevert();
        resolver.setData(dnsEncoded, key, value);
        vm.stopPrank();
    }

    function testSetContenthash() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        bytes memory hash = hex"1234567890";
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);

        vm.prank(owner);
        resolver.setContenthash(dnsEncoded, hash);
        vm.stopPrank();

        assertEq(resolver.contenthash(dnsEncoded), hash);
    }

    function testUnauthorizedSetContenthash() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        bytes memory hash = hex"1234567890";

        vm.prank(address(0x456));
        vm.expectRevert();
        resolver.setContenthash(dnsEncoded, hash);
        vm.stopPrank();
    }

    function testMulticall() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        bytes[] memory data = new bytes[](4);
        data[0] = abi.encodeWithSelector(0xf00eebf4, dnsEncoded, address(0xabc));
        data[1] = abi.encodeCall(resolver.setText, (dnsEncoded, "key", "value"));
        data[2] = abi.encodeCall(resolver.setData, (dnsEncoded, "datakey", hex"1234"));
        data[3] = abi.encodeCall(resolver.setContenthash, (dnsEncoded, hex"1234567890"));

        vm.prank(owner);
        resolver.multicall(data);
        vm.stopPrank();

        assertEq(resolver.addr(dnsEncoded), address(0xabc));
        assertEq(resolver.text(dnsEncoded, "key"), "value");
        assertEq(resolver.data(dnsEncoded, "datakey"), hex"1234");
        assertEq(resolver.contenthash(dnsEncoded), hex"1234567890");
    }

    function testSetTextSubdomain() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(3)), "aaa", bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        string memory value = "value";
        bytes32 node = DNSEncoder.dnsEncodedNamehash(dnsEncoded);

        vm.prank(owner);
        resolver.setText(dnsEncoded, key, value);
        vm.stopPrank();

        assertEq(resolver.text(dnsEncoded, key), value);
    }
}
