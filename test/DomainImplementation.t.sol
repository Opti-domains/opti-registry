// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/DomainImplementation.sol";
import "../src/DomainRoot.sol";

contract TestDomain is DomainImplementation {
    constructor(address _implementation, address _parent, string memory _label) {
        bytes memory immutableArgs =
            abi.encodePacked(_implementation, _parent, uint16(bytes(_label).length), bytes(_label));

        assembly {
            let length := mload(immutableArgs)
            let data := add(immutableArgs, 0x20)
            sstore(0, mload(data))
            if gt(length, 0x20) { sstore(1, mload(add(data, 0x20))) }
        }
    }
}

contract DomainImplementationTest is Test {
    using ClonesWithImmutableArgs for address;

    TestDomain public domain;
    address public implementation;
    address public owner;
    address public resolver;

    function setUp() public {
        implementation = address(new TestDomain(address(0), address(0), ""));
        owner = address(this);
        resolver = address(0x123);

        bytes memory immutableArgs = abi.encodePacked(
            implementation,
            address(0), // parent
            uint16(bytes("test").length), // label length
            bytes("test") // label
        );

        domain = TestDomain(implementation.clone(immutableArgs));
        vm.startPrank(address(0));
        domain.setOwner(owner);
        domain.addAuthorizedDelegate(owner, true);
        vm.stopPrank();
    }

    function testAuthorization() view public {
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
        address subdomain = domain.registerSubdomain("sub", subdomainOwner);

        assertTrue(subdomain != address(0));
        assertEq(domain.subdomains("sub"), subdomain);
        assertEq(TestDomain(subdomain).owner(), subdomainOwner);
    }

    function testGetNestedAddress() public {
        // Register nested subdomains
        address sub1 = domain.registerSubdomain("sub1", address(this));
        domain.setSubdomainOwnerDelegation(true);
        vm.startPrank(address(this));
        TestDomain(sub1).registerSubdomain("sub2", address(this));

        bytes memory dnsEncoded = abi.encodePacked(bytes1(uint8(4)), "sub1", bytes1(uint8(4)), "sub2", bytes1(uint8(0)));

        address nestedAddr = domain.getNestedAddress(dnsEncoded);
        assertTrue(nestedAddr != address(0));
    }

    function testFailUnauthorizedSubdomainRegistration() public {
        vm.prank(address(0x456));
        domain.registerSubdomain("sub", address(this));
    }

    function testFailInvalidLabel() public {
        domain.registerSubdomain("", address(this));
    }
}
