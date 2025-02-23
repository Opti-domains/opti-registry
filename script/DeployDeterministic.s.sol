// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Script, console } from "forge-std/Script.sol";
import { DomainRoot } from "../src/DomainRoot.sol";
import { PermissionedRegistry } from "../src/PermissionedRegistry.sol";
import { SingularResolver } from "../src/SingularResolver.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";
import { TransparentUpgradeableProxy } from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import { ProxyAdmin } from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract DeployDeterministicScript is Script {
    // Zero salt for deterministic deployment
    bytes32 constant ZERO_SALT = bytes32(0);

    function setUp() public { }

    function run() public {
        address deployer = msg.sender;

        // Start broadcasting transactions
        vm.startBroadcast();

        // Get the deterministic addresses
        address implementationLogicAddr =
            vm.computeCreate2Address(ZERO_SALT, keccak256(type(DomainImplementation).creationCode), CREATE2_FACTORY);
        address implementationProxyAddr = vm.computeCreate2Address(
            ZERO_SALT, keccak256(type(TransparentUpgradeableProxy).creationCode), CREATE2_FACTORY
        );
        address rootAddr =
            vm.computeCreate2Address(ZERO_SALT, keccak256(type(DomainRoot).creationCode), CREATE2_FACTORY);
        address resolverLogicAddr =
            vm.computeCreate2Address(ZERO_SALT, keccak256(type(SingularResolver).creationCode), CREATE2_FACTORY);
        address resolverProxyAddr = vm.computeCreate2Address(
            ZERO_SALT, keccak256(type(TransparentUpgradeableProxy).creationCode), CREATE2_FACTORY
        );
        address registryAddr =
            vm.computeCreate2Address(ZERO_SALT, keccak256(type(PermissionedRegistry).creationCode), CREATE2_FACTORY);

        // Print deterministic addresses
        console.log("Implementation Logic:", implementationLogicAddr);
        console.log("Implementation Proxy:", implementationProxyAddr);
        console.log("Resolver Logic:", resolverLogicAddr);
        console.log("Resolver Proxy:", resolverProxyAddr);
        console.log("Root:", rootAddr);
        console.log("Registry:", registryAddr);
        console.log("");

        // Deploy the base implementation contract using CREATE2 if not already deployed
        DomainImplementation implementationLogic = DomainImplementation(implementationLogicAddr);
        if (address(implementationLogic).code.length == 0) {
            implementationLogic = new DomainImplementation{ salt: ZERO_SALT }();
        }

        // Deploy the implementation proxy if not already deployed
        TransparentUpgradeableProxy implementationProxy = TransparentUpgradeableProxy(payable(implementationProxyAddr));
        if (address(implementationProxy).code.length == 0) {
            implementationProxy = new TransparentUpgradeableProxy{ salt: ZERO_SALT }(
                address(implementationLogic),
                address(deployer),
                "" // No initialization data needed
            );
        }

        // Deploy the root domain if not already deployed
        DomainRoot root = DomainRoot(rootAddr);
        if (address(root).code.length == 0) {
            root = new DomainRoot{ salt: ZERO_SALT }(
                address(implementationProxy),
                deployer // Owner
            );
        }

        // Deploy the resolver logic if not already deployed
        SingularResolver resolverLogic = SingularResolver(resolverLogicAddr);
        if (address(resolverLogic).code.length == 0) {
            resolverLogic = new SingularResolver{ salt: ZERO_SALT }(address(root));
        }

        // Deploy the resolver proxy if not already deployed
        TransparentUpgradeableProxy resolverProxy = TransparentUpgradeableProxy(payable(resolverProxyAddr));
        if (address(resolverProxy).code.length == 0) {
            resolverProxy = new TransparentUpgradeableProxy{ salt: ZERO_SALT }(
                address(resolverLogic),
                address(deployer),
                "" // No initialization data needed
            );
        }

        // Set the resolver proxy if not already set
        if (root.resolver() != address(resolverProxy)) {
            root.setResolver(address(resolverProxy));
        }

        // Deploy the permissioned registry if not already deployed
        PermissionedRegistry registry = PermissionedRegistry(registryAddr);
        if (address(registry).code.length == 0) {
            registry = new PermissionedRegistry{ salt: ZERO_SALT }();
        }

        // Setup .eth domain if not already set up
        DomainImplementation ethDomain = DomainImplementation(root.subdomains("eth"));
        if (address(ethDomain) == address(0)) {
            ethDomain = DomainImplementation(root.registerSubdomain("eth", address(deployer)));
            ethDomain.setSubdomainOwnerDelegation(true);
            ethDomain.addAuthorizedDelegate(address(registry), true);
        }

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployed addresses
        console.log("Deployment Addresses:");
        console.log("--------------------");
        console.log("Implementation Logic:", address(implementationLogic));
        console.log("Implementation Proxy:", address(implementationProxy));
        console.log("Resolver Logic:", address(resolverLogic));
        console.log("Resolver Proxy:", address(resolverProxy));
        console.log("Root:", address(root));
        console.log("ETH:", address(ethDomain));
        console.log("Registry:", address(registry));
    }
}
