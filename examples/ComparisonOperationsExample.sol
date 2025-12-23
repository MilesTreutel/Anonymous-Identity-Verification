// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Comparison Operations Example
 * @notice Demonstrates FHE comparison operations: eq, ne, lt, le, gt, ge
 * @dev Shows how to compare encrypted values and get encrypted boolean results
 */
contract ComparisonOperationsExample is ZamaEthereumConfig {
  /// @notice Stores encrypted value A
  euint32 private _valueA;

  /// @notice Stores encrypted value B
  euint32 private _valueB;

  /// @notice Stores encrypted equality comparison (A == B)
  ebool private _equalityResult;

  /// @notice Stores encrypted less-than comparison (A < B)
  ebool private _lessThanResult;

  /// @notice Stores encrypted greater-than comparison (A > B)
  ebool private _greaterThanResult;

  /// @notice Event for comparison results
  event ComparisonPerformed(string indexed operation, address indexed caller);

  /**
   * @notice Set value A for comparisons
   * @param inputA The encrypted value A
   * @param inputProof The input proof
   */
  function setValueA(externalEuint32 inputA, bytes calldata inputProof) external {
    _valueA = FHE.fromExternal(inputA, inputProof);
    FHE.allowThis(_valueA);
  }

  /**
   * @notice Set value B for comparisons
   * @param inputB The encrypted value B
   * @param inputProof The input proof
   */
  function setValueB(externalEuint32 inputB, bytes calldata inputProof) external {
    _valueB = FHE.fromExternal(inputB, inputProof);
    FHE.allowThis(_valueB);
  }

  /**
   * @notice Compare if A == B (equality)
   * @dev Result is an encrypted boolean that only caller can decrypt
   */
  function compareEquality() external {
    // Compare encrypted values for equality
    _equalityResult = FHE.eq(_valueA, _valueB);

    // Grant permissions for result decryption
    FHE.allowThis(_equalityResult);
    FHE.allow(_equalityResult, msg.sender);

    emit ComparisonPerformed("equality", msg.sender);
  }

  /**
   * @notice Compare if A < B (less than)
   * @dev Result is an encrypted boolean that only caller can decrypt
   */
  function compareLessThan() external {
    // Compare encrypted values: A < B
    _lessThanResult = FHE.lt(_valueA, _valueB);

    // Grant permissions for result decryption
    FHE.allowThis(_lessThanResult);
    FHE.allow(_lessThanResult, msg.sender);

    emit ComparisonPerformed("lessThan", msg.sender);
  }

  /**
   * @notice Compare if A > B (greater than)
   * @dev Result is an encrypted boolean that only caller can decrypt
   */
  function compareGreaterThan() external {
    // Compare encrypted values: A > B
    _greaterThanResult = FHE.gt(_valueA, _valueB);

    // Grant permissions for result decryption
    FHE.allowThis(_greaterThanResult);
    FHE.allow(_greaterThanResult, msg.sender);

    emit ComparisonPerformed("greaterThan", msg.sender);
  }

  /**
   * @notice Compare if A <= B (less than or equal)
   * @param outputHandles Output encrypted handles
   */
  function compareLessThanOrEqual() external returns (ebool) {
    ebool result = FHE.le(_valueA, _valueB);
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);
    return result;
  }

  /**
   * @notice Compare if A >= B (greater than or equal)
   * @return The encrypted comparison result
   */
  function compareGreaterThanOrEqual() external returns (ebool) {
    ebool result = FHE.ge(_valueA, _valueB);
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);
    return result;
  }

  /**
   * @notice Compare if A != B (not equal)
   * @return The encrypted comparison result
   */
  function compareNotEqual() external returns (ebool) {
    ebool result = FHE.ne(_valueA, _valueB);
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);
    return result;
  }

  /**
   * @notice Get the equality comparison result
   * @return The encrypted boolean (true if A == B)
   */
  function getEqualityResult() external view returns (ebool) {
    return _equalityResult;
  }

  /**
   * @notice Get the less-than comparison result
   * @return The encrypted boolean (true if A < B)
   */
  function getLessThanResult() external view returns (ebool) {
    return _lessThanResult;
  }

  /**
   * @notice Get the greater-than comparison result
   * @return The encrypted boolean (true if A > B)
   */
  function getGreaterThanResult() external view returns (ebool) {
    return _greaterThanResult;
  }
}
