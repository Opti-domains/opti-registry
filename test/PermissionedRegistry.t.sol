// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { TestDomain } from "./DomainImplementation.t.sol";
import "../src/PermissionedRegistry.sol";
import "../src/DomainRoot.sol";

contract PermissionedRegistryTest is Test {
    PermissionedRegistry public registry;
    DomainRoot public root;
    address public implementation;
    uint256 public ownerPrivateKey;
    address public owner;
    address public resolver;

    function setUp() public {
        implementation = address(new TestDomain(address(0), address(0), ""));
        ownerPrivateKey = 0x1234;
        owner = vm.addr(ownerPrivateKey);
        resolver = address(0x123);

        root = new DomainRoot(implementation, owner, resolver);
        registry = new PermissionedRegistry();
    }

    function testRegisterWithValidSignature() public {
        string memory label = "test";
        address newOwner = address(0xabc);
        uint256 deadline = block.timestamp + 1 hours;
        bytes32 nonce = bytes32(uint256(1));

        bytes32 structHash = registry.getStructHash(address(root), label, newOwner, deadline, nonce);

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", registry.getDomainSeparator(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address subdomain = registry.register(address(root), label, newOwner, deadline, nonce, signature);

        assertTrue(subdomain != address(0));
        assertEq(DomainImplementation(subdomain).owner(), newOwner);
    }

    function testFailExpiredSignature() public {
        string memory label = "test";
        address newOwner = address(0xabc);
        uint256 deadline = block.timestamp - 1 hours;
        bytes32 nonce = bytes32(uint256(1));

        bytes32 structHash = registry.getStructHash(address(root), label, newOwner, deadline, nonce);

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", registry.getDomainSeparator(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        registry.register(address(root), label, newOwner, deadline, nonce, signature);
    }
}
