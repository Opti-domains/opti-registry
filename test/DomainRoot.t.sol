// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";
import "../src/DomainRoot.sol";

contract DomainRootTest is Test {
    DomainRoot public root;
    address public implementation;
    address public owner;
    address public resolver;

    function setUp() public {
        implementation = address(new DomainImplementation());
        owner = address(this);

        root = new DomainRoot(implementation, owner);
    }

    function testRootAuthorization() public {
        assertTrue(root.isAuthorized(owner));
        assertFalse(root.isAuthorized(address(0x456)));
    }

    function testRootProperties() public {
        assertEq(root.parent(), address(0));
        assertEq(root.label(), "");
        assertEq0(root.dnsEncoded(), abi.encodePacked(bytes1(0)));
        assertEq(root.name().length, 0);
        assertEq(root.resolver(), resolver);
    }

    function testRootSubdomainRegistration() public {
        address subdomainOwner = address(0xabc);
        address subdomain = root.registerSubdomain("test", subdomainOwner);

        assertTrue(subdomain != address(0));
        assertEq(root.subdomains("test"), subdomain);
        assertEq(DomainImplementation(subdomain).owner(), subdomainOwner);
    }
}
