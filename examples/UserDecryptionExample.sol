// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title User Decryption Example
 * @dev Demonstrates user-specific decryption patterns
 * @chapter: user-decryption
 */

import { FHE, euint32, euint8, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title User Decryption Contract
 * @notice Shows how to enable users to decrypt their own encrypted data
 * @dev Demonstrates single and multiple value user decryption patterns
 */
contract UserDecryptionExample is ZamaEthereumConfig {
    /// @dev Structure for user's decryptable data
    struct UserDecryptableData {
        euint32 balance;
        euint32 score;
        euint8 level;
        bool canDecrypt;
        uint256 lastUpdate;
    }

    /// @dev Mapping from user to their decryptable data
    mapping(address => UserDecryptableData) public userDecryptableData;

    /// @notice Event when user stores decryptable value
    /// @param user User who stored data
    /// @param timestamp When data was stored
    event DecryptableValueStored(address indexed user, uint256 timestamp);

    /// @notice Event when decryption permission granted
    /// @param user User granted permission
    /// @param grantee Address granted decryption access
    event DecryptionPermissionGranted(
        address indexed user,
        address indexed grantee
    );

    /**
     * @dev Store single encrypted value that user can decrypt
     * @param value Value to store (encrypted by client)
     * @param inputProof Proof of encryption
     * @notice User will be able to decrypt this value
     * @example
     * // Client-side:
     * const value = 12345;
     * const { data, proof } = await fhevmInstance.encrypt_uint32(value);
     * await contract.storeSingleDecryptableValue(data, proof);
     *
     * // Later, user can decrypt:
     * const encrypted = await contract.getMyBalance();
     * const decrypted = await fhevmInstance.decrypt(encrypted);
     */
    function storeSingleDecryptableValue(
        externalEuint32 value,
        bytes calldata inputProof
    ) external {
        // Validate input proof
        euint32 validatedValue = FHE.fromExternal(value, inputProof);

        // Grant contract access
        FHE.allowThis(validatedValue);

        // ✅ CRITICAL: Grant user decryption access
        // This allows the user to decrypt the value later
        FHE.allow(validatedValue, msg.sender);

        // Store with decryption flag
        userDecryptableData[msg.sender].balance = validatedValue;
        userDecryptableData[msg.sender].canDecrypt = true;
        userDecryptableData[msg.sender].lastUpdate = block.timestamp;

        emit DecryptableValueStored(msg.sender, block.timestamp);
    }

    /**
     * @dev Store multiple encrypted values that user can decrypt
     * @param balance User's balance
     * @param balanceProof Proof for balance
     * @param score User's score
     * @param scoreProof Proof for score
     * @param level User's level (0-255)
     * @param levelProof Proof for level
     * @notice All values will be decryptable by the user
     * @example
     * // Encrypt multiple values client-side:
     * const { data: bal, proof: balProof } = await fhevmInstance.encrypt_uint32(1000);
     * const { data: scr, proof: scrProof } = await fhevmInstance.encrypt_uint32(750);
     * const { data: lvl, proof: lvlProof } = await fhevmInstance.encrypt_uint8(5);
     * await contract.storeMultipleDecryptableValues(bal, balProof, scr, scrProof, lvl, lvlProof);
     */
    function storeMultipleDecryptableValues(
        externalEuint32 balance,
        bytes calldata balanceProof,
        externalEuint32 score,
        bytes calldata scoreProof,
        externalEuint8 level,
        bytes calldata levelProof
    ) external {
        // Validate all input proofs
        euint32 validatedBalance = FHE.fromExternal(balance, balanceProof);
        euint32 validatedScore = FHE.fromExternal(score, scoreProof);
        euint8 validatedLevel = FHE.fromExternal(level, levelProof);

        // Grant contract access to all values
        FHE.allowThis(validatedBalance);
        FHE.allowThis(validatedScore);
        FHE.allowThis(validatedLevel);

        // ✅ Grant user decryption access to all values
        FHE.allow(validatedBalance, msg.sender);
        FHE.allow(validatedScore, msg.sender);
        FHE.allow(validatedLevel, msg.sender);

        // Store all decryptable values
        userDecryptableData[msg.sender] = UserDecryptableData({
            balance: validatedBalance,
            score: validatedScore,
            level: validatedLevel,
            canDecrypt: true,
            lastUpdate: block.timestamp
        });

        emit DecryptableValueStored(msg.sender, block.timestamp);
    }

    /**
     * @dev Get your balance (encrypted, you can decrypt it)
     * @return Your encrypted balance
     * @notice You can decrypt this value client-side
     * @example
     * // Client-side decryption:
     * const encryptedBalance = await contract.getMyBalance();
     * const balance = await fhevmInstance.decrypt(encryptedBalance);
     * console.log("My balance:", balance);
     */
    function getMyBalance() external view returns (euint32) {
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );
        return userDecryptableData[msg.sender].balance;
    }

    /**
     * @dev Get your score (encrypted, you can decrypt it)
     * @return Your encrypted score
     * @notice You can decrypt this value client-side
     */
    function getMyScore() external view returns (euint32) {
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );
        return userDecryptableData[msg.sender].score;
    }

    /**
     * @dev Get your level (encrypted, you can decrypt it)
     * @return Your encrypted level
     * @notice You can decrypt this value client-side
     */
    function getMyLevel() external view returns (euint8) {
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );
        return userDecryptableData[msg.sender].level;
    }

    /**
     * @dev Get all your data at once (encrypted, you can decrypt all)
     * @return balance Your encrypted balance
     * @return score Your encrypted score
     * @return level Your encrypted level
     * @notice You can decrypt all these values client-side
     * @example
     * // Client-side batch decryption:
     * const [encBal, encScore, encLevel] = await contract.getAllMyData();
     * const balance = await fhevmInstance.decrypt(encBal);
     * const score = await fhevmInstance.decrypt(encScore);
     * const level = await fhevmInstance.decrypt(encLevel);
     */
    function getAllMyData()
        external
        view
        returns (
            euint32 balance,
            euint32 score,
            euint8 level
        )
    {
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );

        UserDecryptableData storage data = userDecryptableData[msg.sender];
        return (data.balance, data.score, data.level);
    }

    /**
     * @dev Grant another user permission to decrypt your data
     * @param grantee Address to grant decryption permission
     * @notice After this, grantee can decrypt your balance, score, and level
     * @example
     * // Grant decryption access to another user
     * await contract.grantDecryptionPermission('0x123...');
     *
     * // Now user 0x123... can decrypt your data:
     * const encBalance = await contract.getBalanceOf(yourAddress);
     * const balance = await fhevmInstance.decrypt(encBalance);
     */
    function grantDecryptionPermission(address grantee) external {
        require(grantee != address(0), "Invalid address");
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );

        UserDecryptableData storage data = userDecryptableData[msg.sender];

        // Grant decryption access to another user
        FHE.allow(data.balance, grantee);
        FHE.allow(data.score, grantee);
        FHE.allow(data.level, grantee);

        emit DecryptionPermissionGranted(msg.sender, grantee);
    }

    /**
     * @dev Get another user's balance (only if they granted you access)
     * @param user User whose balance to get
     * @return User's encrypted balance (you can decrypt if granted access)
     * @notice Requires user to have granted you decryption permission
     */
    function getBalanceOf(address user) external view returns (euint32) {
        require(userDecryptableData[user].canDecrypt, "User has no data");
        // Access control is handled by FHE layer
        // If user didn't grant access, decryption will fail client-side
        return userDecryptableData[user].balance;
    }

    /**
     * @dev Update your balance (maintains decryption permission)
     * @param newBalance New balance value
     * @param inputProof Proof for new balance
     * @notice Updated value will still be decryptable by you
     */
    function updateMyBalance(
        externalEuint32 newBalance,
        bytes calldata inputProof
    ) external {
        // Validate new value
        euint32 validatedBalance = FHE.fromExternal(newBalance, inputProof);

        // Grant permissions
        FHE.allowThis(validatedBalance);
        FHE.allow(validatedBalance, msg.sender); // ✅ User can still decrypt

        // Update balance
        userDecryptableData[msg.sender].balance = validatedBalance;
        userDecryptableData[msg.sender].lastUpdate = block.timestamp;
    }

    /**
     * @dev Perform operation and return decryptable result
     * @param amount Amount to add to balance
     * @param inputProof Proof for amount
     * @return New encrypted balance (you can decrypt it)
     * @notice Adds amount to your balance, returns decryptable result
     */
    function addToBalance(externalEuint32 amount, bytes calldata inputProof)
        external
        returns (euint32)
    {
        require(
            userDecryptableData[msg.sender].canDecrypt,
            "No decryptable data"
        );

        // Validate input
        euint32 validatedAmount = FHE.fromExternal(amount, inputProof);

        // Perform homomorphic addition
        euint32 newBalance = FHE.add(
            userDecryptableData[msg.sender].balance,
            validatedAmount
        );

        // Grant permissions to result
        FHE.allowThis(newBalance);
        FHE.allow(newBalance, msg.sender); // ✅ User can decrypt result

        // Update balance
        userDecryptableData[msg.sender].balance = newBalance;
        userDecryptableData[msg.sender].lastUpdate = block.timestamp;

        return newBalance; // User can decrypt this!
    }

    /**
     * @dev Check if you have decryptable data stored
     * @return true if you can decrypt your data
     */
    function canIDecrypt() external view returns (bool) {
        return userDecryptableData[msg.sender].canDecrypt;
    }

    /**
     * @dev Get timestamp of last update (public info)
     * @return Timestamp of last data update
     */
    function getLastUpdateTime() external view returns (uint256) {
        return userDecryptableData[msg.sender].lastUpdate;
    }
}

/**
 * USER DECRYPTION GUIDE:
 *
 * CLIENT-SIDE DECRYPTION WORKFLOW:
 *
 * 1. Get encrypted value from contract:
 *    const encrypted = await contract.getMyBalance();
 *
 * 2. Decrypt using fhevmInstance:
 *    const decrypted = await fhevmInstance.decrypt(encrypted);
 *
 * 3. Use the plaintext value:
 *    console.log("My balance:", decrypted);
 *
 * KEY POINTS:
 *
 * ✅ Use FHE.allow(value, userAddress) to grant decryption access
 * ✅ User can only decrypt values they have permission for
 * ✅ Decryption happens client-side, not in contract
 * ✅ Multiple users can have decryption access to same value
 * ✅ Decryption requires user's private key (via wallet)
 *
 * SECURITY NOTES:
 *
 * - Decryption access cannot be revoked once granted
 * - Once decrypted, value is known to user forever
 * - Grant decryption access carefully
 * - Consider implications before sharing access
 *
 * BATCH DECRYPTION:
 *
 * For efficiency, get multiple values and decrypt in parallel:
 *
 * const [encBal, encScore, encLevel] = await contract.getAllMyData();
 * const [bal, score, level] = await Promise.all([
 *   fhevmInstance.decrypt(encBal),
 *   fhevmInstance.decrypt(encScore),
 *   fhevmInstance.decrypt(encLevel)
 * ]);
 */
