// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Confidential ERC20 Token (Simplified ERC7984)
 * @notice A simplified implementation of confidential token transfer
 * @dev Demonstrates privacy-preserving token balances and transfers using FHE
 *
 * This is inspired by OpenZeppelin's ERC7984 confidential contracts standard
 */
contract ConfidentialERC20 is ZamaEthereumConfig {
  /// @notice Token name
  string public name;

  /// @notice Token symbol
  string public symbol;

  /// @notice Total supply (public for simplicity, can be encrypted)
  uint256 public totalSupply;

  /// @notice Mapping from address to encrypted balance
  mapping(address => euint32) private _balances;

  /// @notice Event for transfers (amounts are encrypted)
  event Transfer(address indexed from, address indexed to);

  /// @notice Event for minting
  event Mint(address indexed to, uint256 amount);

  /**
   * @notice Constructor
   * @param tokenName The name of the token
   * @param tokenSymbol The symbol of the token
   */
  constructor(string memory tokenName, string memory tokenSymbol) {
    name = tokenName;
    symbol = tokenSymbol;
    totalSupply = 0;
  }

  /**
   * @notice Mint tokens to an address with encrypted amount
   * @param to The recipient address
   * @param amount The amount to mint (plaintext for simplicity)
   */
  function mint(address to, uint32 amount) external {
    require(to != address(0), "Cannot mint to zero address");

    // Create encrypted amount
    euint32 encryptedAmount = FHE.asEuint32(amount);

    // Add to balance
    euint32 newBalance = FHE.add(_balances[to], encryptedAmount);

    // Grant permissions
    FHE.allowThis(newBalance);
    FHE.allow(newBalance, to);

    _balances[to] = newBalance;
    totalSupply += amount;

    emit Mint(to, amount);
  }

  /**
   * @notice Transfer encrypted tokens
   * @param to The recipient address
   * @param encryptedAmount The encrypted amount to transfer
   * @param inputProof The input proof for the encrypted amount
   */
  function transfer(
    address to,
    externalEuint32 encryptedAmount,
    bytes calldata inputProof
  ) external {
    require(to != address(0), "Cannot transfer to zero address");
    require(to != msg.sender, "Cannot transfer to self");

    // Validate and import encrypted amount
    euint32 amount = FHE.fromExternal(encryptedAmount, inputProof);
    FHE.allowThis(amount);

    // Subtract from sender balance
    euint32 newSenderBalance = FHE.sub(_balances[msg.sender], amount);

    // Add to recipient balance
    euint32 newRecipientBalance = FHE.add(_balances[to], amount);

    // Grant permissions
    FHE.allowThis(newSenderBalance);
    FHE.allow(newSenderBalance, msg.sender);

    FHE.allowThis(newRecipientBalance);
    FHE.allow(newRecipientBalance, to);

    // Update balances
    _balances[msg.sender] = newSenderBalance;
    _balances[to] = newRecipientBalance;

    emit Transfer(msg.sender, to);
  }

  /**
   * @notice Get encrypted balance of an address
   * @param account The account address
   * @return The encrypted balance
   */
  function balanceOf(address account) external view returns (euint32) {
    return _balances[account];
  }

  /**
   * @notice Check if sender has sufficient balance (encrypted comparison)
   * @param encryptedAmount The amount to check
   * @param inputProof The input proof
   * @return Encrypted boolean indicating if balance is sufficient
   */
  function hasSufficientBalance(
    externalEuint32 encryptedAmount,
    bytes calldata inputProof
  ) external view returns (euint32) {
    euint32 amount = FHE.fromExternal(encryptedAmount, inputProof);
    // This would return ebool in a more complete implementation
    return _balances[msg.sender];
  }
}
