// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISingularResolverAuthorizer {
    function isResolverAuthorized(
        bytes32 node,
        address caller,
        bytes calldata data
    ) external view returns (bool);
}
