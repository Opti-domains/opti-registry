// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DomainImplementation.sol";
import "../src/DomainRoot.sol";

contract DomainImplementationTest is Test {
    using ClonesWithImmutableArgs for address;

    DomainRoot public root;
    DomainImplementation public domain;
    address public implementation;
    address public owner;
    address public resolver;

    function setUp() public {
        implementation = address(new DomainImplementation());
        owner = address(this);

        root = new DomainRoot(implementation, owner);
        root.setSubdomainOwnerDelegation(true, true);

        domain = DomainImplementation(root.registerSubdomain("test", owner));
    }

    function testAuthorization() public view {
        assertTrue(domain.isAuthorized(address(this)));
        assertFalse(domain.isAuthorized(address(0x456)));
    }

    function testDelegateAuthorization() public {
        address delegate = address(0x789);
        domain.addAuthorizedDelegate(delegate, true);
        assertTrue(domain.isAuthorized(delegate));

        domain.addAuthorizedDelegate(delegate, false);
        assertFalse(domain.isAuthorized(delegate));
    }

    function testRegisterSubdomain() public {
        address subdomainOwner = address(0xabc);
        DomainImplementation subdomain = DomainImplementation(domain.registerSubdomain("sub", subdomainOwner));

        assertTrue(address(subdomain) != address(0));
        assertEq(domain.subdomains("sub"), address(subdomain));
        assertEq(DomainImplementation(subdomain).owner(), subdomainOwner);

        vm.expectRevert(DomainImplementation.SubdomainOwnerDelegationPermanent.selector);
        domain.setSubdomainOwnerDelegation(false, true);

        assertFalse(subdomain.isAuthorized(subdomainOwner));
        domain.setSubdomainOwnerDelegation(true, false);
        assertTrue(subdomain.isAuthorized(subdomainOwner));
        domain.setSubdomainOwnerDelegation(false, false);
        assertFalse(subdomain.isAuthorized(subdomainOwner));
        domain.setSubdomainOwnerDelegation(true, true);
        assertTrue(subdomain.isAuthorized(subdomainOwner));

        vm.expectRevert(DomainImplementation.SubdomainOwnerDelegationPermanent.selector);
        domain.setSubdomainOwnerDelegation(false, false);
    }

    function testGetNestedAddress() public {
        // Register nested subdomains
        address sub1 = domain.registerSubdomain("sub1", address(this));
        domain.setSubdomainOwnerDelegation(true, true);
        DomainImplementation(sub1).registerSubdomain("sub2", address(this));

        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "sub1", bytes1(uint8(4)), "sub2", bytes1(uint8(0)));

        address nestedAddr = domain.getNestedAddress(dnsEncoded);
        assertTrue(nestedAddr != address(0));
    }

    function testUnauthorizedSubdomainRegistration() public {
        vm.prank(address(0x456));
        vm.expectRevert(DomainImplementation.Unauthorized.selector);
        domain.registerSubdomain("sub", address(this));
    }

    function testInvalidLabel() public {
        vm.expectRevert(DomainImplementation.InvalidLabel.selector);
        domain.registerSubdomain("", address(this));
    }
}
