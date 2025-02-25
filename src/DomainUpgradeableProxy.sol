// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./interfaces/IDomain.sol";

/**
 * @title DomainUpgradeableProxy
 * @notice Proxy contract that delegates calls to an implementation contract specified by the parent domain
 * @dev Based on OpenZeppelin's TransparentUpgradeableProxy pattern but gets implementation from parent
 */
contract DomainUpgradeableProxy is TransparentUpgradeableProxy {
    /**
     * @dev Initializes the proxy with initial implementation and optional initialization data
     */
    constructor(address _logic, address initialOwner, bytes memory _data)
        payable
        TransparentUpgradeableProxy(_logic, initialOwner, _data)
    { }

    /// @return offset The offset of the packed immutable args in calldata
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        // solhint-disable-next-line no-inline-assembly
        assembly {
            offset := sub(calldatasize(), add(shr(240, calldataload(sub(calldatasize(), 2))), 2))
        }
    }

    /// @notice Reads an immutable arg with type address
    /// @param argOffset The offset of the arg in the packed data
    /// @return arg The arg value
    function _getArgAddress(uint256 argOffset) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }

    /// @notice Gets the implementation contract address for subdomains
    function implementation() public view virtual returns (address) {
        address superImplementation = super._implementation();
        if (superImplementation == address(0)) {
            // IMPLEMENTATION_OFFSET = 0
            address impl = _getArgAddress(0);
            return IDomain(impl).implementation();
        }
        return superImplementation;
    }

    /**
     * @dev Returns the current implementation address.
     *
     * TIP: To get this value clients can read directly from the storage slot shown below (specified by ERC-1967) using
     * the https://eth.wiki/json-rpc/API#eth_getstorageat[`eth_getStorageAt`] RPC call.
     * `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
     */
    function _implementation() internal view virtual override returns (address) {
        return implementation();
    }
}
