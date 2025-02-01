// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import { Script, console } from "forge-std/Script.sol";
import { DomainRoot } from "../src/DomainRoot.sol";
import { PermissionedRegistry } from "../src/PermissionedRegistry.sol";
import { SingularResolver } from "../src/SingularResolver.sol";
import { DomainImplementation } from "../src/DomainImplementation.sol";

contract DeployScript is Script {
    function setUp() public { }

    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the base implementation contract
        DomainImplementation implementation = new DomainImplementation();

        // Deploy the root domain with the implementation and resolver
        address deployer = msg.sender;
        DomainRoot root = new DomainRoot(
            address(implementation),
            deployer // Owner
        );

        // Deploy the resolver
        SingularResolver resolver = new SingularResolver(address(root));

        // Set the resolver
        root.setResolver(address(resolver));

        // Deploy the permissioned registry
        PermissionedRegistry registry = new PermissionedRegistry();

        // Setup initial permissions
        root.addAuthorizedDelegate(address(registry), true);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployed addresses
        console.log("Deployment Addresses:");
        console.log("--------------------");
        console.log("Implementation:", address(implementation));
        console.log("Resolver:", address(resolver));
        console.log("Root:", address(root));
        console.log("Registry:", address(registry));
    }
}
