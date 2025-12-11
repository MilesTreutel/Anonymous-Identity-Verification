// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title FHEVM Encryption Example
 * @dev Demonstrates single and multiple value encryption patterns
 * @chapter: encryption-patterns
 */

import { FHE, euint32, euint8, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title Contract demonstrating encryption and decryption patterns
contract EncryptionExample is ZamaEthereumConfig {
    /// @dev Structure to store encrypted data
    struct EncryptedData {
        euint32 primaryValue;
        euint32 secondaryValue;
        euint8 dataType;
        bool isActive;
        uint256 timestamp;
    }

    /// @dev Mapping to store encrypted data per user
    mapping(address => EncryptedData) public userEncryptedData;

    /// @notice Event for single value encryption
    /// @param user The user whose data was encrypted
    /// @param timestamp When encryption occurred
    event SingleValueEncrypted(address indexed user, uint256 timestamp);

    /// @notice Event for multiple value encryption
    /// @param user The user whose data was encrypted
    /// @param valueCount Number of values encrypted
    /// @param timestamp When encryption occurred
    event MultipleValuesEncrypted(address indexed user, uint32 valueCount, uint256 timestamp);

    /**
     * @dev Encrypt a single value and store it
     * @param value The value to encrypt
     * @notice The value is converted to encrypted form and stored securely
     * @notice Only the contract can access this encrypted value
     * @example
     * // Encrypt the value 12345 for the caller
     * await contract.encryptSingleValue(12345);
     */
    function encryptSingleValue(uint32 value) external {
        require(value > 0, "Value must be positive");

        // Convert plaintext to encrypted format
        euint32 encryptedValue = FHE.asEuint32(value);

        // Grant contract-level access to encrypted value
        FHE.allowThis(encryptedValue);

        // Store encrypted value
        userEncryptedData[msg.sender].primaryValue = encryptedValue;
        userEncryptedData[msg.sender].dataType = 0;
        userEncryptedData[msg.sender].isActive = true;
        userEncryptedData[msg.sender].timestamp = block.timestamp;

        emit SingleValueEncrypted(msg.sender, block.timestamp);
    }

    /**
     * @dev Encrypt multiple values and store them
     * @param value1 First value to encrypt
     * @param value2 Second value to encrypt
     * @param dataType Classification of the data (0-255)
     * @notice Both values are encrypted and stored securely
     * @notice Demonstrates managing multiple encrypted values per user
     * @example
     * // Encrypt two values with data type 1 (credential data)
     * await contract.encryptMultipleValues(54321, 98765, 1);
     */
    function encryptMultipleValues(
        uint32 value1,
        uint32 value2,
        uint8 dataType
    ) external {
        require(value1 > 0, "Value1 must be positive");
        require(value2 > 0, "Value2 must be positive");

        // Encrypt first value
        euint32 encrypted1 = FHE.asEuint32(value1);
        FHE.allowThis(encrypted1);

        // Encrypt second value
        euint32 encrypted2 = FHE.asEuint32(value2);
        FHE.allowThis(encrypted2);

        // Encrypt data type indicator
        euint8 encryptedType = FHE.asEuint8(dataType);
        FHE.allowThis(encryptedType);

        // Store all encrypted values
        userEncryptedData[msg.sender] = EncryptedData({
            primaryValue: encrypted1,
            secondaryValue: encrypted2,
            dataType: encryptedType,
            isActive: true,
            timestamp: block.timestamp
        });

        emit MultipleValuesEncrypted(msg.sender, 2, block.timestamp);
    }

    /**
     * @dev Get encrypted data for a user
     * @param user The user address
     * @return Primary encrypted value
     * @return Secondary encrypted value
     * @return Data type indicator
     * @return Whether data is active
     * @notice Returns encrypted values that only authorized parties can decrypt
     */
    function getEncryptedData(address user)
        external
        view
        returns (
            euint32,
            euint32,
            euint8,
            bool
        )
    {
        EncryptedData storage data = userEncryptedData[user];
        return (
            data.primaryValue,
            data.secondaryValue,
            data.dataType,
            data.isActive
        );
    }

    /**
     * @dev Check if user has encrypted data stored
     * @param user The user address
     * @return true if user has active encrypted data
     */
    function hasEncryptedData(address user) external view returns (bool) {
        return userEncryptedData[user].isActive;
    }

    /**
     * @dev Clear encrypted data for a user
     * @notice Once cleared, data cannot be recovered
     */
    function clearEncryptedData() external {
        delete userEncryptedData[msg.sender];
    }

    /**
     * @dev Perform homomorphic operation on stored encrypted values
     * @notice Demonstrates adding two encrypted values together
     * @notice Result remains encrypted
     */
    function addStoredValues() external view returns (euint32) {
        EncryptedData storage data = userEncryptedData[msg.sender];

        require(data.isActive, "No active data");

        // Add encrypted values while keeping result encrypted
        return FHE.add(data.primaryValue, data.secondaryValue);
    }

    /**
     * @dev Perform homomorphic comparison on encrypted values
     * @notice Checks if primary value equals secondary value
     * @notice Result is encrypted boolean
     */
    function compareStoredValues() external view returns (ebool) {
        EncryptedData storage data = userEncryptedData[msg.sender];

        require(data.isActive, "No active data");

        // Compare encrypted values (result remains encrypted)
        return FHE.eq(data.primaryValue, data.secondaryValue);
    }
}
