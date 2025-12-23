// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Arithmetic Operations Example
 * @notice Demonstrates FHE arithmetic operations: add, subtract, multiply
 * @dev Shows how to perform computations on encrypted values
 */
contract ArithmeticOperationsExample is ZamaEthereumConfig {
  /// @notice Stores encrypted operand A
  euint32 private _operandA;

  /// @notice Stores encrypted operand B
  euint32 private _operandB;

  /// @notice Stores the result of addition
  euint32 private _additionResult;

  /// @notice Stores the result of subtraction
  euint32 private _subtractionResult;

  /// @notice Stores the result of multiplication
  euint32 private _multiplicationResult;

  /**
   * @notice Set the first encrypted operand
   * @param inputA The encrypted operand A
   * @param inputProof The input proof
   */
  function setOperandA(externalEuint32 inputA, bytes calldata inputProof) external {
    _operandA = FHE.fromExternal(inputA, inputProof);
    FHE.allowThis(_operandA);
  }

  /**
   * @notice Set the second encrypted operand
   * @param inputB The encrypted operand B
   * @param inputProof The input proof
   */
  function setOperandB(externalEuint32 inputB, bytes calldata inputProof) external {
    _operandB = FHE.fromExternal(inputB, inputProof);
    FHE.allowThis(_operandB);
  }

  /**
   * @notice Compute A + B on encrypted values
   * @dev Result is stored and accessible to caller
   */
  function computeAddition() external {
    // Perform encrypted addition
    _additionResult = FHE.add(_operandA, _operandB);

    // Grant permissions for result decryption
    FHE.allowThis(_additionResult);
    FHE.allow(_additionResult, msg.sender);
  }

  /**
   * @notice Compute A - B on encrypted values
   * @dev Result is stored and accessible to caller
   */
  function computeSubtraction() external {
    // Perform encrypted subtraction
    _subtractionResult = FHE.sub(_operandA, _operandB);

    // Grant permissions for result decryption
    FHE.allowThis(_subtractionResult);
    FHE.allow(_subtractionResult, msg.sender);
  }

  /**
   * @notice Compute A * B on encrypted values
   * @dev Result is stored and accessible to caller
   * @notice Multiplication is more expensive than addition/subtraction
   */
  function computeMultiplication() external {
    // Perform encrypted multiplication
    _multiplicationResult = FHE.mul(_operandA, _operandB);

    // Grant permissions for result decryption
    FHE.allowThis(_multiplicationResult);
    FHE.allow(_multiplicationResult, msg.sender);
  }

  /**
   * @notice Get the addition result
   * @return The encrypted A + B value
   */
  function getAdditionResult() external view returns (euint32) {
    return _additionResult;
  }

  /**
   * @notice Get the subtraction result
   * @return The encrypted A - B value
   */
  function getSubtractionResult() external view returns (euint32) {
    return _subtractionResult;
  }

  /**
   * @notice Get the multiplication result
   * @return The encrypted A * B value
   */
  function getMultiplicationResult() external view returns (euint32) {
    return _multiplicationResult;
  }

  /**
   * @notice Compute chained operations: (A + B) * 2
   * @dev Demonstrates combining multiple operations
   */
  function computeChainedOperations() external {
    // First: A + B
    euint32 sum = FHE.add(_operandA, _operandB);

    // Then: sum * 2 (multiply by constant)
    _multiplicationResult = FHE.mul(sum, 2);

    FHE.allowThis(_multiplicationResult);
    FHE.allow(_multiplicationResult, msg.sender);
  }
}
