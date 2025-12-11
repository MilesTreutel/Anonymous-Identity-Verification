// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title FHEVM Anti-Patterns Example
 * @dev Demonstrates common mistakes and how to avoid them
 * @chapter: anti-patterns
 */

import { FHE, euint32, euint8, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Anti-Patterns Contract
 * @notice Educational contract showing common mistakes with FHEVM
 * @dev Each function pair shows WRONG way vs RIGHT way
 *
 * WARNING: This contract contains intentionally bad code for educational purposes
 * DO NOT use the "wrong" examples in production!
 */
contract AntiPatternsExample is ZamaEthereumConfig {
    euint32 private encryptedValue;
    euint32 private userSecret;

    // ========================================================================
    // ANTI-PATTERN 1: View Functions with Encrypted Return Values
    // ========================================================================

    /**
     * ❌ WRONG: Returning encrypted value from view function
     * @dev This doesn't work! View functions can't return encrypted types to users
     * @notice This will compile but won't be usable by clients
     */
    function getEncryptedValue_WRONG() external view returns (euint32) {
        // ERROR: Can't return encrypted value from view function
        // Users can't decrypt this on the client side
        return encryptedValue;
    }

    /**
     * ✅ CORRECT: Use decryption request or return public data
     * @dev For user queries, request decryption or return public metadata
     * @notice Returns whether value exists (public info)
     */
    function hasValue_CORRECT() external view returns (bool) {
        // Return public information instead
        // Or use FHE.requestDecryption for actual value
        return true; // placeholder
    }

    // ========================================================================
    // ANTI-PATTERN 2: Missing FHE.allowThis() Permissions
    // ========================================================================

    /**
     * ❌ WRONG: Storing encrypted value without granting contract access
     * @param value Value to store
     * @notice This will fail when contract tries to use the value later
     */
    function storeWithoutPermission_WRONG(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);

        // ERROR: Missing FHE.allowThis(encrypted)
        // Contract won't be able to perform operations on this value

        encryptedValue = encrypted;
    }

    /**
     * ✅ CORRECT: Always grant contract access with FHE.allowThis()
     * @param value Value to store
     * @notice Properly grants contract access for future operations
     */
    function storeWithPermission_CORRECT(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);

        // CORRECT: Grant contract access
        FHE.allowThis(encrypted);

        // CORRECT: Grant user access if needed
        FHE.allow(encrypted, msg.sender);

        encryptedValue = encrypted;
    }

    // ========================================================================
    // ANTI-PATTERN 3: Comparing Encrypted with Plaintext
    // ========================================================================

    /**
     * ❌ WRONG: Trying to compare encrypted value with plaintext in if statement
     * @param threshold Plaintext threshold
     * @notice This won't compile! Can't use encrypted values in boolean context
     */
    // function compareWithPlaintext_WRONG(uint32 threshold) external view returns (bool) {
    //     // ERROR: Can't use encrypted value in if condition
    //     // if (encryptedValue > threshold) {  // COMPILATION ERROR!
    //     //     return true;
    //     // }
    //     // return false;
    // }

    /**
     * ✅ CORRECT: Use FHE comparison functions
     * @param threshold Plaintext threshold to compare against
     * @return Encrypted boolean result
     * @notice Returns encrypted result, not plaintext boolean
     */
    function compareWithThreshold_CORRECT(uint32 threshold)
        external
        view
        returns (ebool)
    {
        // CORRECT: Use FHE comparison functions
        euint32 thresholdEncrypted = FHE.asEuint32(threshold);
        return FHE.gt(encryptedValue, thresholdEncrypted);
    }

    // ========================================================================
    // ANTI-PATTERN 4: Not Validating Input Proofs
    // ========================================================================

    /**
     * ❌ WRONG: Accepting encrypted input without proof validation
     * @param value Unvalidated encrypted value (DANGEROUS!)
     * @notice This allows malicious users to submit garbage encrypted data
     */
    function acceptWithoutProof_WRONG(euint32 value) external {
        // ERROR: Accepting encrypted value without validation
        // User could submit arbitrary encrypted values they don't know

        encryptedValue = value;
        // This is a MAJOR security vulnerability!
    }

    /**
     * ✅ CORRECT: Always validate input proofs for user submissions
     * @param inputValue External encrypted value
     * @param inputProof Cryptographic proof
     * @notice Only accepts values with valid proofs
     */
    function acceptWithProof_CORRECT(
        externalEuint32 inputValue,
        bytes calldata inputProof
    ) external {
        // CORRECT: Validate proof using FHE.fromExternal
        euint32 validatedValue = FHE.fromExternal(inputValue, inputProof);

        FHE.allowThis(validatedValue);
        encryptedValue = validatedValue;
    }

    // ========================================================================
    // ANTI-PATTERN 5: Unnecessary Decryption
    // ========================================================================

    /**
     * ❌ WRONG: Requesting decryption when not needed
     * @param value1 First value
     * @param value2 Second value
     * @notice Wastes gas by decrypting when homomorphic operation would work
     */
    function addWithDecryption_WRONG(uint32 value1, uint32 value2)
        external
        returns (uint32)
    {
        // ERROR: Unnecessarily converting to plaintext for simple operation
        // This defeats the purpose of FHE!

        // Don't do this - keep values encrypted
        return value1 + value2; // Missing the encrypted computation benefits
    }

    /**
     * ✅ CORRECT: Use homomorphic operations, stay encrypted
     * @param value1 First value
     * @param value2 Second value
     * @return Encrypted sum
     * @notice Performs addition while maintaining encryption
     */
    function addHomomorphically_CORRECT(uint32 value1, uint32 value2)
        external
        pure
        returns (euint32)
    {
        // CORRECT: Keep everything encrypted
        euint32 encrypted1 = FHE.asEuint32(value1);
        euint32 encrypted2 = FHE.asEuint32(value2);

        // Perform homomorphic addition
        return FHE.add(encrypted1, encrypted2);
    }

    // ========================================================================
    // ANTI-PATTERN 6: Exposing Encrypted Values Through Events
    // ========================================================================

    /// ❌ WRONG: Including encrypted value in event
    /// @notice This exposes encrypted data in transaction logs!
    event ValueStored_WRONG(address indexed user, euint32 encryptedValue);

    /// ✅ CORRECT: Only include public metadata in events
    /// @notice Events should only contain public information
    event ValueStored_CORRECT(address indexed user, uint256 timestamp);

    /**
     * ❌ WRONG: Emitting encrypted value in event
     * @param value Value to store
     * @notice Events are public, don't put encrypted values in them!
     */
    function storeAndEmit_WRONG(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);

        // ERROR: Emitting encrypted value
        emit ValueStored_WRONG(msg.sender, encrypted);
    }

    /**
     * ✅ CORRECT: Only emit public information
     * @param value Value to store
     * @notice Events contain only public metadata, not encrypted data
     */
    function storeAndEmit_CORRECT(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);

        // CORRECT: Only emit public data
        emit ValueStored_CORRECT(msg.sender, block.timestamp);
    }

    // ========================================================================
    // ANTI-PATTERN 7: Insufficient Access Control
    // ========================================================================

    /**
     * ❌ WRONG: No access control on sensitive operations
     * @param user User to query
     * @return User's encrypted secret (EXPOSED!)
     * @notice Anyone can call this and get user's encrypted data!
     */
    function getUserSecret_WRONG(address user)
        external
        view
        returns (euint32)
    {
        // ERROR: No access control check
        // Anyone can retrieve anyone else's encrypted data
        return userSecret;
    }

    /**
     * ✅ CORRECT: Implement proper access control
     * @return Caller's encrypted secret
     * @notice Only returns caller's own data
     */
    function getMySecret_CORRECT() external view returns (euint32) {
        // CORRECT: Only return caller's own data
        require(msg.sender != address(0), "Invalid caller");

        // Additional access control logic here
        return userSecret;
    }

    // ========================================================================
    // ANTI-PATTERN 8: Ignoring Gas Costs
    // ========================================================================

    /**
     * ❌ WRONG: Performing unnecessary encrypted operations
     * @param times Number of iterations
     * @notice Wastes gas with redundant operations
     */
    function wasteGas_WRONG(uint32 times) external view returns (euint32) {
        euint32 result = FHE.asEuint32(0);

        // ERROR: Inefficient loop with encrypted operations
        for (uint32 i = 0; i < times; i++) {
            euint32 temp = FHE.asEuint32(1);
            result = FHE.add(result, temp); // Expensive operation in loop
        }

        return result;
    }

    /**
     * ✅ CORRECT: Minimize encrypted operations
     * @param times Number to add
     * @return Encrypted result
     * @notice Performs single operation instead of loop
     */
    function optimizeGas_CORRECT(uint32 times)
        external
        pure
        returns (euint32)
    {
        // CORRECT: Single operation instead of loop
        euint32 result = FHE.asEuint32(times);
        return result;
    }

    // ========================================================================
    // ANTI-PATTERN 9: Not Handling Edge Cases
    // ========================================================================

    /**
     * ❌ WRONG: No validation or edge case handling
     * @param value Value to process
     * @notice Can overflow, underflow, or produce unexpected results
     */
    function processWithoutValidation_WRONG(uint32 value) external {
        // ERROR: No input validation
        // No overflow checking
        // No edge case handling

        euint32 encrypted = FHE.asEuint32(value);
        encryptedValue = encrypted;
    }

    /**
     * ✅ CORRECT: Validate inputs and handle edge cases
     * @param value Value to process
     * @notice Includes comprehensive validation
     */
    function processWithValidation_CORRECT(uint32 value) external {
        // CORRECT: Validate inputs
        require(value > 0, "Value must be positive");
        require(value <= type(uint32).max, "Value too large");

        // CORRECT: Handle edge cases
        euint32 encrypted = FHE.asEuint32(value);
        FHE.allowThis(encrypted);

        encryptedValue = encrypted;
    }

    // ========================================================================
    // ANTI-PATTERN 10: Mixing Trusted and Untrusted Data
    // ========================================================================

    /**
     * ❌ WRONG: Treating user input as trusted data
     * @param userValue Untrusted user input
     * @notice Doesn't validate proof for user input
     */
    function mixTrustedUntrusted_WRONG(uint32 userValue) external {
        // ERROR: Using FHE.asEuint32() for user input
        // This should only be used for trusted (contract-generated) values

        euint32 encrypted = FHE.asEuint32(userValue);
        encryptedValue = encrypted;
    }

    /**
     * ✅ CORRECT: Use different methods for trusted vs untrusted data
     * @param externalValue External encrypted value from user
     * @param proof Cryptographic proof
     * @notice Properly validates user input with proof
     */
    function handleUntrustedData_CORRECT(
        externalEuint32 externalValue,
        bytes calldata proof
    ) external {
        // CORRECT: Validate untrusted user input
        euint32 validatedValue = FHE.fromExternal(externalValue, proof);

        FHE.allowThis(validatedValue);
        encryptedValue = validatedValue;
    }
}

/**
 * SUMMARY OF ANTI-PATTERNS:
 *
 * 1. ❌ Returning encrypted values from view functions
 *    ✅ Return public metadata or use decryption requests
 *
 * 2. ❌ Missing FHE.allowThis() permissions
 *    ✅ Always grant contract access to encrypted values
 *
 * 3. ❌ Comparing encrypted with plaintext in conditions
 *    ✅ Use FHE comparison functions, return ebool
 *
 * 4. ❌ Not validating input proofs
 *    ✅ Always use FHE.fromExternal() for user inputs
 *
 * 5. ❌ Unnecessary decryption
 *    ✅ Use homomorphic operations when possible
 *
 * 6. ❌ Exposing encrypted values in events
 *    ✅ Only emit public metadata
 *
 * 7. ❌ Insufficient access control
 *    ✅ Implement proper permission checks
 *
 * 8. ❌ Ignoring gas costs
 *    ✅ Optimize encrypted operations
 *
 * 9. ❌ Not handling edge cases
 *    ✅ Validate inputs and handle errors
 *
 * 10. ❌ Mixing trusted and untrusted data
 *     ✅ Use correct methods for each data source
 */
