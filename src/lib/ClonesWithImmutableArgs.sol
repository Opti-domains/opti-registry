// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/// @title ClonesWithImmutableArgs
/// @author wighawag, zefram.eth
/// @notice Enables creating clone contracts with immutable args
library ClonesWithImmutableArgs {
    error CreateFailed();

    /// @notice Creates a clone proxy of the implementation contract
    /// @dev The implementation is assumed to use the clone pattern with immutable args
    /// @param implementation The implementation contract to clone
    /// @param data Encoded immutable args
    /// @return instance The address of the created clone
    function clone(
        address implementation,
        bytes memory data
    ) internal returns (address instance) {
        // unrealistic for memory ptr or data length to exceed 256 bits
        unchecked {
            uint256 extraLength = data.length;
            uint256 creationSize = 0x41 + extraLength;
            uint256 runSize = creationSize - 10;
            uint256 dataPtr;
            uint256 ptr;

            // Get the pointer to free memory and check that
            // it's properly aligned for copying code
            assembly {
                ptr := mload(0x40)
                dataPtr := add(ptr, 0x4f)
            }

            // Copy creation code
            ptr = _copyCreationCode(ptr, implementation);

            // Copy runtime code
            _copyRuntimeCode(ptr, extraLength, runSize);

            // Copy immutable args
            _copyImmutableArgs(dataPtr, data);

            // Create the proxy clone
            assembly {
                instance := create(0, ptr, creationSize)
            }

            if (instance == address(0)) {
                revert CreateFailed();
            }

            // Restore free memory pointer
            assembly {
                mstore(0x40, add(dataPtr, extraLength))
            }
        }
    }

    /// @dev Copies the creation code from implementation
    function _copyCreationCode(
        uint256 ptr,
        address implementation
    ) private pure returns (uint256) {
        assembly {
            mstore(
                ptr,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(
                add(ptr, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
        }
        return ptr + 0x35;
    }

    /// @dev Copies the runtime code
    function _copyRuntimeCode(
        uint256 ptr,
        uint256 extraLength,
        uint256 runSize
    ) private pure {
        assembly {
            mstore(
                ptr,
                0x363d3d373d3d3d363d3d73000000000000000000000000000000000000000000
            )
            mstore(add(ptr, 0xa), shl(0x60, address()))
            mstore(
                add(ptr, 0x1e),
                0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000
            )
            mstore(add(ptr, 0x32), shl(0xf0, runSize))
        }
    }

    /// @dev Copies the immutable args
    function _copyImmutableArgs(
        uint256 dataPtr,
        bytes memory data
    ) private pure {
        assembly {
            let length := mload(data)
            pop(staticcall(gas(), 4, add(data, 0x20), length, dataPtr, length))
        }
    }
}
