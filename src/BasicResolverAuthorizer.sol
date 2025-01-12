// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interfaces/ISingularResolverAuthorizer.sol";
import "./interfaces/IDomain.sol";
import "./lib/DNSEncoder.sol";

contract BasicResolverAuthorizer is ISingularResolverAuthorizer {
    IDomain public immutable root;

    constructor(address _root) {
        root = IDomain(_root);
    }

    function isResolverAuthorized(bytes calldata dnsEncoded, address caller, bytes calldata)
        external
        view
        returns (bool)
    {
        bytes memory reversedName = DNSEncoder.reverseDnsEncoded(dnsEncoded);
        address domainAddr = root.getNestedAddress(reversedName);
        return IDomain(domainAddr).isAuthorized(caller);
    }
}
