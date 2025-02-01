// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";
import "../src/PermissionedRegistry.sol";
import "../src/DomainRoot.sol";

contract PermissionedRegistryTest is Test {
    using ClonesWithImmutableArgs for address;

    PermissionedRegistry public registry;
    DomainImplementation public root;
    address public implementation;
    uint256 public ownerPrivateKey;
    address public owner;
    address public resolver;

    function setUp() public {
        implementation = address(new DomainImplementation());
        ownerPrivateKey = 0x1234;
        owner = vm.addr(ownerPrivateKey);

        root = new DomainRoot(implementation, owner);
        registry = new PermissionedRegistry();
        vm.startPrank(owner);
        root.addAuthorizedDelegate(address(registry), true);
        vm.stopPrank();
    }

    function testRegisterWithValidSignature() public {
        string memory label = "test";
        address newOwner = address(0xabc);
        uint256 deadline = vm.getBlockTimestamp() + 1 hours;
        bytes32 nonce = bytes32(uint256(1));

        bytes32 structHash = registry.getStructHash(address(root), label, newOwner, deadline, nonce);

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", registry.getDomainSeparator(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address subdomain = registry.register(address(root), label, newOwner, deadline, nonce, signature);

        assertTrue(subdomain != address(0));
        assertEq(DomainImplementation(subdomain).owner(), newOwner);
    }

    function testExpiredSignature() public {
        vm.warp(1738428733);

        string memory label = "test";
        address newOwner = address(0xabc);
        uint256 deadline = vm.getBlockTimestamp() - 1 hours;
        bytes32 nonce = bytes32(uint256(1));

        bytes32 structHash = registry.getStructHash(address(root), label, newOwner, deadline, nonce);

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", registry.getDomainSeparator(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.expectRevert(PermissionedRegistry.InvalidSignature.selector);
        registry.register(address(root), label, newOwner, deadline, nonce, signature);
    }
}
