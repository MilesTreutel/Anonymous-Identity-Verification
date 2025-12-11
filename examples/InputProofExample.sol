// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

/**
 * @title Input Proof Example
 * @dev Demonstrates proper use of input proofs in FHEVM
 * @chapter: input-proofs
 */

import { FHE, euint32, externalEuint32, ebool } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Input Proof Contract
 * @notice Demonstrates why input proofs are needed and how to use them correctly
 * @dev Input proofs ensure that encrypted inputs come from legitimate sources
 *
 * Key Concept: Input proofs prevent malicious users from submitting arbitrary
 * encrypted values that they don't know the plaintext for.
 */
contract InputProofExample is ZamaEthereumConfig {
    /// @dev Structure to store encrypted user data with proof validation
    struct UserData {
        euint32 value;
        address owner;
        uint256 timestamp;
        bool validated;
    }

    /// @dev Mapping from user to their validated encrypted data
    mapping(address => UserData) public userData;

    /// @notice Event emitted when data is submitted with valid proof
    /// @param user User who submitted data
    /// @param timestamp When data was submitted
    event DataSubmittedWithProof(address indexed user, uint256 timestamp);

    /// @notice Event emitted when data validation fails
    /// @param user User whose submission failed
    /// @param reason Reason for failure
    event ValidationFailed(address indexed user, string reason);

    /**
     * @dev Submit encrypted value WITH input proof (CORRECT METHOD)
     * @param inputEuint32 External encrypted value from client
     * @param inputProof Cryptographic proof that user knows the plaintext
     * @notice This is the CORRECT way to accept encrypted user input
     * @notice The proof ensures the user actually encrypted the value themselves
     *
     * @example
     * // Client-side (JavaScript):
     * const value = 12345;
     * const { data, proof } = await fhevmInstance.encrypt_uint32(value);
     * await contract.submitWithProof(data, proof);
     */
    function submitWithProof(
        externalEuint32 inputEuint32,
        bytes calldata inputProof
    ) external {
        // Convert external encrypted value to internal format
        // This step VALIDATES the proof and ensures the user knows the plaintext
        euint32 validatedValue = FHE.fromExternal(inputEuint32, inputProof);

        // Grant contract access to the validated encrypted value
        FHE.allowThis(validatedValue);

        // Grant user access for future queries
        FHE.allow(validatedValue, msg.sender);

        // Store the validated data
        userData[msg.sender] = UserData({
            value: validatedValue,
            owner: msg.sender,
            timestamp: block.timestamp,
            validated: true
        });

        emit DataSubmittedWithProof(msg.sender, block.timestamp);
    }

    /**
     * @dev Submit multiple encrypted values with proofs
     * @param value1 First external encrypted value
     * @param proof1 Proof for first value
     * @param value2 Second external encrypted value
     * @param proof2 Proof for second value
     * @notice Demonstrates handling multiple input proofs in one transaction
     *
     * @example
     * // Client-side:
     * const { data: data1, proof: proof1 } = await fhevmInstance.encrypt_uint32(111);
     * const { data: data2, proof: proof2 } = await fhevmInstance.encrypt_uint32(222);
     * await contract.submitMultipleWithProofs(data1, proof1, data2, proof2);
     */
    function submitMultipleWithProofs(
        externalEuint32 value1,
        bytes calldata proof1,
        externalEuint32 value2,
        bytes calldata proof2
    ) external {
        // Validate both input proofs
        euint32 validated1 = FHE.fromExternal(value1, proof1);
        euint32 validated2 = FHE.fromExternal(value2, proof2);

        // Perform homomorphic operation on validated values
        euint32 sum = FHE.add(validated1, validated2);

        // Grant access
        FHE.allowThis(sum);
        FHE.allow(sum, msg.sender);

        // Store the computed result
        userData[msg.sender] = UserData({
            value: sum,
            owner: msg.sender,
            timestamp: block.timestamp,
            validated: true
        });

        emit DataSubmittedWithProof(msg.sender, block.timestamp);
    }

    /**
     * @dev Compare encrypted input against stored value
     * @param inputEuint32 External encrypted value to compare
     * @param inputProof Proof for the input
     * @return Encrypted boolean result of comparison
     * @notice Demonstrates using input proofs in comparison operations
     */
    function compareWithProof(
        externalEuint32 inputEuint32,
        bytes calldata inputProof
    ) external view returns (ebool) {
        require(userData[msg.sender].validated, "No validated data");

        // Validate the input proof
        euint32 validatedInput = FHE.fromExternal(inputEuint32, inputProof);

        // Compare validated input with stored value
        return FHE.eq(userData[msg.sender].value, validatedInput);
    }

    /**
     * @dev Get stored data (only owner can access)
     * @return Encrypted value owned by caller
     */
    function getMyData() external view returns (euint32) {
        require(userData[msg.sender].validated, "No validated data");
        return userData[msg.sender].value;
    }

    /**
     * @dev Check if user has validated data
     * @return true if user has submitted data with valid proof
     */
    function hasValidatedData() external view returns (bool) {
        return userData[msg.sender].validated;
    }

    /**
     * @dev Perform operation on validated data
     * @param multiplier Plain value to multiply by
     * @return Result of multiplication (encrypted)
     * @notice Only works on data that was submitted with valid proof
     */
    function multiplyValidatedData(uint32 multiplier)
        external
        view
        returns (euint32)
    {
        require(userData[msg.sender].validated, "No validated data");
        require(multiplier > 0, "Multiplier must be positive");

        euint32 multiplierEncrypted = FHE.asEuint32(multiplier);
        return FHE.mul(userData[msg.sender].value, multiplierEncrypted);
    }
}

/**
 * WHY INPUT PROOFS ARE NEEDED:
 *
 * Without input proofs, a malicious user could:
 * 1. Submit arbitrary encrypted values they don't know
 * 2. Manipulate the system by providing "garbage" encrypted data
 * 3. Break the security model of the application
 *
 * Input proofs ensure that:
 * - The user encrypted the value themselves
 * - They know the plaintext value
 * - The encrypted value is legitimate
 *
 * HOW TO USE INPUT PROOFS:
 *
 * 1. Client-side encryption (JavaScript/TypeScript):
 *    const { data, proof } = await fhevmInstance.encrypt_uint32(value);
 *
 * 2. Submit to contract:
 *    await contract.submitWithProof(data, proof);
 *
 * 3. Contract validates and converts:
 *    euint32 validated = FHE.fromExternal(data, proof);
 *
 * 4. Now safe to use in computations
 *
 * COMMON MISTAKES TO AVOID:
 * - ❌ Accepting encrypted values without proof validation
 * - ❌ Using FHE.asEuint32() for user inputs (only for trusted values)
 * - ❌ Skipping proof validation "for testing"
 * - ❌ Not storing validated status
 *
 * BEST PRACTICES:
 * - ✅ Always validate input proofs for user-submitted data
 * - ✅ Use FHE.fromExternal() for all external encrypted inputs
 * - ✅ Store validation status in your data structures
 * - ✅ Emit events when validation succeeds or fails
 * - ✅ Check validated status before operations
 */
