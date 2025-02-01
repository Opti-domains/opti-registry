// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";
import "../src/SingularResolver.sol";
import "../src/DomainRoot.sol";

contract SingularResolverTest is Test {
    SingularResolver public resolver;
    DomainRoot public root;
    address public implementation;
    address public owner;

    function setUp() public {
        implementation = address(new DomainImplementation());
        owner = address(this);

        root = new DomainRoot(implementation, owner);
        root.registerSubdomain("test", owner);
        root.setSubdomainOwnerDelegation(true);

        resolver = new SingularResolver(address(root));
        root.setResolver(address(resolver));
    }

    function testSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        address addr = address(0xabc);

        vm.prank(owner);
        resolver.setAddr(addr, dnsEncoded);
        vm.stopPrank();

        assertEq(resolver.addr(dnsEncoded), addr);
    }

    function testSetText() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        string memory key = "test";
        string memory value = "value";

        vm.prank(owner);
        resolver.setText(key, value, dnsEncoded);
        vm.stopPrank();

        assertEq(resolver.text(dnsEncoded, key), value);
    }

    function testFailUnauthorizedSetAddr() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        vm.prank(address(0x456));
        resolver.setAddr(address(0xabc), dnsEncoded);
        vm.stopPrank();
    }

    function testSetContenthash() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        bytes memory hash = hex"1234567890";

        vm.prank(owner);
        resolver.setContenthash(hash, dnsEncoded);
        vm.stopPrank();
        assertEq(resolver.contenthash(dnsEncoded), hash);
    }

    function testFailUnauthorizedSetContenthash() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));
        bytes memory hash = hex"1234567890";

        vm.prank(address(0x456));
        resolver.setContenthash(hash, dnsEncoded);
        vm.stopPrank();
    }

    function testMulticall() public {
        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "test", bytes1(uint8(0)));

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeCall(resolver.setAddr, (address(0xabc), dnsEncoded));
        data[1] = abi.encodeCall(resolver.setText, ("key", "value", dnsEncoded));

        vm.prank(owner);
        resolver.multicall(data);
        vm.stopPrank();
        assertEq(resolver.addr(dnsEncoded), address(0xabc));
        assertEq(resolver.text(dnsEncoded, "key"), "value");
    }
}
