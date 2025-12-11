// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title Fully Homomorphic Encryption Counter
 * @dev Simple counter using FHEVM for encrypted state management
 * @chapter: basic-counter
 */

import { FHE, euint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title A simple FHE counter contract demonstrating encrypted arithmetic
contract FHECounter is ZamaEthereumConfig {
    /// @dev Encrypted counter value stored on-chain
    euint32 private counter;

    /// @notice Event emitted when counter is incremented
    /// @param value The increment amount (public for audit)
    /// @param timestamp Block timestamp of operation
    event CounterIncremented(uint32 indexed value, uint256 timestamp);

    /// @notice Event emitted when counter is decremented
    /// @param value The decrement amount (public for audit)
    /// @param timestamp Block timestamp of operation
    event CounterDecremented(uint32 indexed value, uint256 timestamp);

    /// @dev Initialize counter to zero
    constructor() {
        counter = FHE.asEuint32(0);
        FHE.allowThis(counter);
    }

    /**
     * @dev Increment encrypted counter by a specific value
     * @param value Amount to increment (unencrypted)
     * @notice The counter remains encrypted throughout the operation
     * @notice This demonstrates homomorphic addition on encrypted data
     * @example
     * // Add 5 to counter while maintaining encryption
     * await contract.increment(5);
     */
    function increment(uint32 value) external {
        require(value > 0, "Increment value must be positive");

        // Convert value to encrypted form
        euint32 encryptedValue = FHE.asEuint32(value);

        // Perform homomorphic addition
        counter = FHE.add(counter, encryptedValue);

        // Grant access to contract for future operations
        FHE.allowThis(counter);

        emit CounterIncremented(value, block.timestamp);
    }

    /**
     * @dev Decrement encrypted counter by a specific value
     * @param value Amount to decrement (unencrypted)
     * @notice The counter remains encrypted throughout the operation
     * @notice This demonstrates homomorphic subtraction on encrypted data
     * @example
     * // Subtract 3 from counter while maintaining encryption
     * await contract.decrement(3);
     */
    function decrement(uint32 value) external {
        require(value > 0, "Decrement value must be positive");

        // Convert value to encrypted form
        euint32 encryptedValue = FHE.asEuint32(value);

        // Perform homomorphic subtraction
        counter = FHE.sub(counter, encryptedValue);

        // Grant access to contract for future operations
        FHE.allowThis(counter);

        emit CounterDecremented(value, block.timestamp);
    }

    /**
     * @dev Get current counter value (returns encrypted value)
     * @return Encrypted counter value
     * @notice The returned value is encrypted and only accessible to authorized parties
     * @notice Contract has access through FHE.allowThis()
     */
    function getCounter() external view returns (euint32) {
        return counter;
    }

    /**
     * @dev Reset counter to zero
     * @notice Only callable by contract owner (for demo purposes)
     */
    function reset() external {
        counter = FHE.asEuint32(0);
        FHE.allowThis(counter);
    }
}
