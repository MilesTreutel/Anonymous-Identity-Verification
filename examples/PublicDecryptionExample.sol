// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Public Decryption Example
 * @notice Demonstrates public decryption using FHE.makePubliclyDecryptable()
 * @dev Shows how to create values that can be decrypted by anyone without requiring FHE permissions
 */
contract PublicDecryptionExample is ZamaEthereumConfig {
  /// @notice Stores a publicly decryptable encrypted value
  euint32 private _publiclyDecryptableValue;

  /// @notice Counter for tracking games/requests
  uint256 private _counter = 0;

  /// @notice Stores the game state with encrypted result
  struct Game {
    address player1;
    address player2;
    euint32 encryptedResult;
    uint256 createdAt;
  }

  /// @notice Mapping of game ID to game state
  mapping(uint256 => Game) public games;

  /// @notice Event emitted when a public decryptable value is created
  event PublicValueCreated(uint256 indexed gameId, euint32 encryptedValue);

  /// @notice Event emitted when decryption is verified
  event DecryptionVerified(uint256 indexed gameId, uint32 decryptedValue);

  /**
   * @notice Create a publicly decryptable encrypted value
   * @dev This value can be decrypted by anyone without special permissions
   * @param inputValue The encrypted input value
   * @param inputProof The input proof for validation
   */
  function createPublicValue(externalEuint32 inputValue, bytes calldata inputProof) external {
    euint32 encryptedValue = FHE.fromExternal(inputValue, inputProof);
    FHE.allowThis(encryptedValue);

    // Make the value publicly decryptable - anyone can decrypt this
    FHE.makePubliclyDecryptable(encryptedValue);

    _publiclyDecryptableValue = encryptedValue;
    _counter++;

    uint256 gameId = _counter;
    games[gameId] = Game({
      player1: msg.sender,
      player2: address(0),
      encryptedResult: encryptedValue,
      createdAt: block.timestamp
    });

    emit PublicValueCreated(gameId, encryptedValue);
  }

  /**
   * @notice Get the publicly decryptable value
   * @return The encrypted value handle that can be decrypted publicly
   */
  function getPublicValue() external view returns (euint32) {
    return _publiclyDecryptableValue;
  }

  /**
   * @notice Verify a public decryption result
   * @param gameId The game ID
   * @param abiEncodedClearValue The ABI-encoded clear value from decryption
   * @param decryptionProof The proof of valid decryption
   */
  function verifyPublicDecryption(
    uint256 gameId,
    bytes memory abiEncodedClearValue,
    bytes memory decryptionProof
  ) external {
    Game storage game = games[gameId];
    require(game.createdAt != 0, "Game does not exist");

    // Verify the decryption proof
    bytes32[] memory cts = new bytes32[](1);
    cts[0] = FHE.toBytes32(game.encryptedResult);

    FHE.checkSignatures(cts, abiEncodedClearValue, decryptionProof);

    // Decode and use the decrypted value
    uint32 decryptedValue = abi.decode(abiEncodedClearValue, (uint32));

    emit DecryptionVerified(gameId, decryptedValue);
  }

  /**
   * @notice Get game details
   * @param gameId The game ID
   * @return The game struct
   */
  function getGame(uint256 gameId) external view returns (Game memory) {
    return games[gameId];
  }
}
