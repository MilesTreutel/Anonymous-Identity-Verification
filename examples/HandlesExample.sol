// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Handles Understanding Example
 * @notice Demonstrates how FHE handles work in FHEVM
 * @dev Explains handle generation, lifecycle, and symbolic execution
 *
 * KEY CONCEPTS:
 * 1. Handles are unique identifiers for encrypted values
 * 2. Handles are generated deterministically during symbolic execution
 * 3. Handle lifecycle: creation -> permissions -> operations -> decryption
 * 4. Handles can be converted to/from bytes32 for storage and events
 */
contract HandlesExample is ZamaEthereumConfig {
  /// @notice Mapping to store encrypted values by user
  mapping(address => euint32) private _userValues;

  /// @notice Mapping to store handles as bytes32
  mapping(address => bytes32) private _userHandles;

  /// @notice Event to demonstrate handle emission
  event HandleCreated(address indexed user, bytes32 handle);

  /**
   * @notice Create an encrypted value and store its handle
   * @param inputValue The encrypted input value
   * @param inputProof The input proof
   *
   * Handle Generation Process:
   * 1. FHE.fromExternal creates a new encrypted value
   * 2. FHEVM generates a unique handle for this ciphertext
   * 3. Handle is deterministic based on ciphertext and context
   * 4. Handle can be extracted using FHE.toBytes32()
   */
  function createValue(externalEuint32 inputValue, bytes calldata inputProof) external {
    // Create encrypted value - this generates a handle internally
    euint32 encryptedValue = FHE.fromExternal(inputValue, inputProof);

    // Grant permissions to the handle
    FHE.allowThis(encryptedValue);
    FHE.allow(encryptedValue, msg.sender);

    // Store the encrypted value (handle is stored internally)
    _userValues[msg.sender] = encryptedValue;

    // Extract and store the handle as bytes32
    bytes32 handle = FHE.toBytes32(encryptedValue);
    _userHandles[msg.sender] = handle;

    // Emit the handle for off-chain tracking
    emit HandleCreated(msg.sender, handle);
  }

  /**
   * @notice Demonstrates handle lifecycle through operations
   * @dev Each operation creates a new handle for the result
   *
   * Handle Lifecycle:
   * 1. Input handles: handles for stored values
   * 2. Operation: FHE.add creates NEW handle for result
   * 3. Permission: new handle needs permissions
   * 4. Result: new handle represents new ciphertext
   */
  function performOperation(address otherUser) external {
    // Get two encrypted values (each has its own handle)
    euint32 value1 = _userValues[msg.sender];
    euint32 value2 = _userValues[otherUser];

    // Operation creates NEW encrypted value with NEW handle
    euint32 result = FHE.add(value1, value2);

    // The result has a DIFFERENT handle than inputs
    // New handle needs permissions
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);

    // Store result (with its new handle)
    _userValues[msg.sender] = result;
  }

  /**
   * @notice Get the handle for a user's stored value
   * @param user The user address
   * @return The bytes32 representation of the handle
   *
   * Handle Properties:
   * - Unique identifier for each ciphertext
   * - Can be converted to/from euint types
   * - Persists across storage/retrieval
   * - Used for permission management
   */
  function getHandle(address user) external view returns (bytes32) {
    return _userHandles[user];
  }

  /**
   * @notice Get the encrypted value for a user
   * @param user The user address
   * @return The encrypted value (handle)
   */
  function getValue(address user) external view returns (euint32) {
    return _userValues[user];
  }

  /**
   * @notice Demonstrates symbolic execution with handles
   * @dev During contract execution, handles are processed symbolically
   *
   * Symbolic Execution:
   * 1. Contract code is executed symbolically during validation
   * 2. Handles are tracked through operations
   * 3. Permission checks verified symbolically
   * 4. Actual encrypted operations happen in FHEVM backend
   */
  function demonstrateSymbolicExecution(
    externalEuint32 inputA,
    bytes calldata proofA,
    externalEuint32 inputB,
    bytes calldata proofB
  ) external returns (euint32) {
    // Step 1: Create handles from inputs
    euint32 a = FHE.fromExternal(inputA, proofA);
    euint32 b = FHE.fromExternal(inputB, proofB);

    // Step 2: Symbolic execution tracks permissions
    FHE.allowThis(a);
    FHE.allowThis(b);

    // Step 3: Operation creates new handle symbolically
    euint32 result = FHE.mul(a, b);

    // Step 4: New handle gets permissions
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);

    // Throughout this process:
    // - EVM executes symbolically
    // - FHEVM backend performs actual FHE operations
    // - Handles link EVM state to FHE ciphertexts

    return result;
  }

  /**
   * @notice Demonstrates handle equality and comparison
   * @dev Two handles are equal only if they refer to the same ciphertext
   */
  function compareHandles(address user1, address user2) external view returns (bool) {
    bytes32 handle1 = _userHandles[user1];
    bytes32 handle2 = _userHandles[user2];

    // Handles are equal only if they reference the exact same ciphertext
    // Different ciphertexts (even with same plaintext) have different handles
    return handle1 == handle2;
  }
}
