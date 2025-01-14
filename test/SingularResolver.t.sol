// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { TestDomain } from "./DomainImplementation.t.sol";
import "../src/SingularResolver.sol";
import "../src/BasicResolverAuthorizer.sol";
import "../src/DomainRoot.sol";

contract SingularResolverTest is Test {
    SingularResolver public resolver;
    BasicResolverAuthorizer public authorizer;
    DomainRoot public root;
    address public implementation;
    address public owner;

    function setUp() public {
        implementation = address(new TestDomain(address(0), address(0), ""));
        owner = address(this);

        root = new DomainRoot(implementation, owner, address(0));
        root.registerSubdomain("test", owner);
        root.setSubdomainOwnerDelegation(true);
        resolver = new SingularResolver();
        authorizer = new BasicResolverAuthorizer(address(root));
    }

    function testSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        address addr = address(0xabc);

        vm.prank(owner);
        resolver.setAddr(addr, dnsEncoded, authorizer);
        vm.prank(address(authorizer));
        assertEq(resolver.addr(dnsEncoded), addr);
    }

    function testSetText() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        string memory value = "value";

        resolver.setText(key, value, dnsEncoded, authorizer);
        vm.prank(address(authorizer));
        assertEq(resolver.text(dnsEncoded, key), value);
    }

    function testFailUnauthorizedSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        vm.prank(address(0x456));
        resolver.setAddr(address(0xabc), dnsEncoded, authorizer);
    }

    function testMulticall() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(resolver.setAddr, (address(0xabc), dnsEncoded, authorizer));
        data[1] = abi.encodeCall(resolver.setText, ("key", "value", dnsEncoded, authorizer));

        resolver.multicall(data);
        vm.startPrank(address(authorizer));
        assertEq(resolver.addr(dnsEncoded), address(0xabc));
        assertEq(resolver.text(dnsEncoded, "key"), "value");
    }
}
