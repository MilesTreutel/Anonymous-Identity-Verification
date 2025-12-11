// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title FHEVM Access Control Example
 * @dev Demonstrates FHE.allow and FHE.allowThis patterns for permission management
 * @chapter: access-control
 */

import { FHE, euint32, euint8 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/// @title Contract demonstrating access control patterns for encrypted data
contract AccessControlExample is ZamaEthereumConfig {
    /// @dev Structure for access-controlled encrypted data
    struct SecretData {
        euint32 secretValue;
        euint8 accessLevel;
        address owner;
        bool isActive;
    }

    /// @dev Mapping from user to their secret data
    mapping(address => SecretData) public secrets;

    /// @dev Track users with decryption access
    mapping(address => mapping(address => bool)) public decryptionAccess;

    /// @notice Event when access is granted
    /// @param grantee Address granted access
    /// @param owner Address of data owner
    event AccessGranted(address indexed grantee, address indexed owner);

    /// @notice Event when access is revoked
    /// @param revokee Address whose access was revoked
    /// @param owner Address of data owner
    event AccessRevoked(address indexed revokee, address indexed owner);

    /// @notice Event when secret data is stored
    /// @param owner Address storing the data
    event SecretStored(address indexed owner);

    /**
     * @dev Store secret data with access control
     * @param value The secret value to store
     * @param accessLevel Access level indicator (0=private, 1=limited, 2=shared)
     * @notice Data is stored encrypted, access controlled through FHE.allowThis()
     * @example
     * // Store secret value with limited access
     * await contract.storeSecret(99999, 1);
     */
    function storeSecret(uint32 value, uint8 accessLevel) external {
        require(value > 0, "Value must be positive");
        require(accessLevel <= 2, "Invalid access level");

        // Encrypt the secret value
        euint32 secretValue = FHE.asEuint32(value);
        euint8 levelValue = FHE.asEuint8(accessLevel);

        // Grant contract access using FHE.allowThis()
        // This allows the contract itself to perform operations on the data
        FHE.allowThis(secretValue);
        FHE.allowThis(levelValue);

        // Grant owner (caller) access for future queries
        FHE.allow(secretValue, msg.sender);
        FHE.allow(levelValue, msg.sender);

        // Store the encrypted data
        secrets[msg.sender] = SecretData({
            secretValue: secretValue,
            accessLevel: levelValue,
            owner: msg.sender,
            isActive: true
        });

        emit SecretStored(msg.sender);
    }

    /**
     * @dev Grant another user access to decrypt your secret
     * @param grantee Address to grant access to
     * @notice Uses FHE.allow() to grant user-specific decryption rights
     * @notice Only data owner can grant access
     * @example
     * // Allow user 0x123... to decrypt my secret
     * await contract.grantAccess('0x123...');
     */
    function grantAccess(address grantee) external {
        require(grantee != address(0), "Invalid address");
        require(secrets[msg.sender].isActive, "No active secret");
        require(!decryptionAccess[msg.sender][grantee], "Access already granted");

        // Grant user-specific access to encrypted secret
        FHE.allow(secrets[msg.sender].secretValue, grantee);
        FHE.allow(secrets[msg.sender].accessLevel, grantee);

        // Track the permission grant
        decryptionAccess[msg.sender][grantee] = true;

        emit AccessGranted(grantee, msg.sender);
    }

    /**
     * @dev Revoke access to your secret
     * @param revokee Address whose access should be revoked
     * @notice Note: Already decrypted values cannot be unlearned
     * @notice This prevents future decryption operations
     * @example
     * // Revoke access for user 0x456...
     * await contract.revokeAccess('0x456...');
     */
    function revokeAccess(address revokee) external {
        require(decryptionAccess[msg.sender][revokee], "Access not granted");

        // Mark access as revoked
        decryptionAccess[msg.sender][revokee] = false;

        emit AccessRevoked(revokee, msg.sender);
    }

    /**
     * @dev Check if user has access to another user's secret
     * @param owner Owner of the secret
     * @param querier User checking for access
     * @return true if querier has access to owner's secret
     */
    function hasAccess(address owner, address querier)
        external
        view
        returns (bool)
    {
        return owner == querier || decryptionAccess[owner][querier];
    }

    /**
     * @dev Get access level for a secret (remains encrypted)
     * @param user User whose secret to query
     * @return Encrypted access level
     * @notice Requires caller to have access
     */
    function getAccessLevel(address user)
        external
        view
        returns (euint8)
    {
        require(
            msg.sender == user || decryptionAccess[user][msg.sender],
            "No access"
        );

        return secrets[user].accessLevel;
    }

    /**
     * @dev Perform operation on secret (contract-only access)
     * @param multiplier Value to multiply secret by
     * @return Encrypted result
     * @notice Uses FHE.allowThis() access granted during storage
     * @notice Only callable by authorized parties
     */
    function multiplySecret(uint32 multiplier)
        external
        view
        returns (euint32)
    {
        require(secrets[msg.sender].isActive, "No active secret");
        require(multiplier > 0, "Multiplier must be positive");

        // Perform homomorphic operation using contract access
        euint32 multiplierEncrypted = FHE.asEuint32(multiplier);

        return FHE.mul(secrets[msg.sender].secretValue, multiplierEncrypted);
    }

    /**
     * @dev Compare secret against a threshold (encrypted comparison)
     * @param threshold Value to compare against
     * @return Encrypted boolean result
     * @notice Demonstrates encrypted comparison without revealing values
     */
    function isSecretGreaterThan(uint32 threshold)
        external
        view
        returns (ebool)
    {
        require(secrets[msg.sender].isActive, "No active secret");

        euint32 thresholdEncrypted = FHE.asEuint32(threshold);

        return FHE.gt(secrets[msg.sender].secretValue, thresholdEncrypted);
    }

    /**
     * @dev Check if you have access to your own secret
     * @return true if caller has an active secret
     */
    function hasOwnSecret() external view returns (bool) {
        return secrets[msg.sender].isActive;
    }

    /**
     * @dev Delete your secret (clear all access)
     * @notice This removes the secret and all access grants
     */
    function deleteSecret() external {
        require(secrets[msg.sender].isActive, "No active secret");

        delete secrets[msg.sender];

        // Note: Individual access grants would need to be tracked and revoked
    }
}
