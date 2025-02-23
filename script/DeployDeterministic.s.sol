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

        // Deploy the base implementation contract using CREATE2
        DomainImplementation implementationLogic = new DomainImplementation{ salt: ZERO_SALT }();

        // Deploy the implementation proxy
        TransparentUpgradeableProxy implementationProxy = new TransparentUpgradeableProxy{ salt: ZERO_SALT }(
            address(implementationLogic),
            address(deployer),
            "" // No initialization data needed
        );

        // Deploy the root domain with the implementation proxy and resolver using CREATE2
        DomainRoot root = new DomainRoot{ salt: ZERO_SALT }(
            address(implementationProxy),
            deployer // Owner
        );

        // Deploy the resolver logic using CREATE2
        SingularResolver resolverLogic = new SingularResolver{ salt: ZERO_SALT }(address(root));

        // Deploy the resolver proxy
        TransparentUpgradeableProxy resolverProxy = new TransparentUpgradeableProxy{ salt: ZERO_SALT }(
            address(resolverLogic),
            address(deployer),
            "" // No initialization data needed
        );

        // Set the resolver proxy
        root.setResolver(address(resolverProxy));

        // Deploy the permissioned registry using CREATE2
        PermissionedRegistry registry = new PermissionedRegistry{ salt: ZERO_SALT }();

        // Setup .eth domain
        DomainImplementation ethDomain = DomainImplementation(root.registerSubdomain("eth", address(deployer)));

        // Enable .eth domain owner to own their domains
        ethDomain.setSubdomainOwnerDelegation(true);

        // Setup registrar
        ethDomain.addAuthorizedDelegate(address(registry), true);

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
