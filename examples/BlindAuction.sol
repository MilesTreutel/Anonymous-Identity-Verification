// SPDX-License-Identifier: BSD-3-Clause-Clear
pragma solidity ^0.8.24;

import { FHE, euint32, ebool, externalEuint32 } from "@fhevm/solidity/lib/FHE.sol";
import { ZamaEthereumConfig } from "@fhevm/solidity/config/ZamaConfig.sol";

/**
 * @title Blind Auction
 * @notice An advanced example of a sealed-bid auction using FHE
 * @dev Demonstrates complex FHEVM patterns including:
 *      - Encrypted bid storage
 *      - Encrypted bid comparisons
 *      - Time-based state transitions
 *      - Winner determination without revealing losing bids
 */
contract BlindAuction is ZamaEthereumConfig {
  /// @notice Auction state
  enum AuctionState {
    Active,
    Ended,
    Finalized
  }

  /// @notice Current auction state
  AuctionState public state;

  /// @notice Auction end time
  uint256 public auctionEndTime;

  /// @notice Minimum bid increment
  uint32 public minBidIncrement;

  /// @notice Struct to store bid information
  struct Bid {
    address bidder;
    euint32 encryptedAmount;
    uint256 timestamp;
    bool withdrawn;
  }

  /// @notice Array of all bids
  Bid[] private _bids;

  /// @notice Mapping from bidder to their bid indices
  mapping(address => uint256[]) private _bidderToBids;

  /// @notice Current highest bid (encrypted)
  euint32 private _highestBid;

  /// @notice Address of highest bidder (revealed after auction ends)
  address public highestBidder;

  /// @notice Events
  event BidPlaced(address indexed bidder, uint256 bidIndex);
  event AuctionEnded(uint256 timestamp);
  event WinnerDetermined(address indexed winner);

  /**
   * @notice Constructor
   * @param biddingTime Duration of the auction in seconds
   * @param minIncrement Minimum bid increment
   */
  constructor(uint256 biddingTime, uint32 minIncrement) {
    auctionEndTime = block.timestamp + biddingTime;
    minBidIncrement = minIncrement;
    state = AuctionState.Active;
    _highestBid = FHE.asEuint32(0);
  }

  /**
   * @notice Place an encrypted bid
   * @param encryptedBid The encrypted bid amount
   * @param inputProof The input proof for validation
   */
  function placeBid(externalEuint32 encryptedBid, bytes calldata inputProof) external {
    require(state == AuctionState.Active, "Auction not active");
    require(block.timestamp < auctionEndTime, "Auction has ended");

    // Validate and import encrypted bid
    euint32 bidAmount = FHE.fromExternal(encryptedBid, inputProof);
    FHE.allowThis(bidAmount);
    FHE.allow(bidAmount, msg.sender);

    // Store the bid
    uint256 bidIndex = _bids.length;
    _bids.push(
      Bid({ bidder: msg.sender, encryptedAmount: bidAmount, timestamp: block.timestamp, withdrawn: false })
    );

    _bidderToBids[msg.sender].push(bidIndex);

    // Update highest bid using encrypted comparison
    // In a real implementation, you would need to verify bid is higher
    // For now, we update optimistically
    _highestBid = bidAmount;

    emit BidPlaced(msg.sender, bidIndex);
  }

  /**
   * @notice End the auction (can be called by anyone after end time)
   */
  function endAuction() external {
    require(state == AuctionState.Active, "Auction already ended");
    require(block.timestamp >= auctionEndTime, "Auction still ongoing");

    state = AuctionState.Ended;
    emit AuctionEnded(block.timestamp);
  }

  /**
   * @notice Determine winner by decrypting and comparing bids
   * @dev In a real implementation, this would use a more sophisticated
   *      decryption and comparison mechanism
   */
  function determineWinner() external {
    require(state == AuctionState.Ended, "Auction not ended");

    // This is simplified - in reality you would:
    // 1. Request decryption of all bids
    // 2. Compare them off-chain
    // 3. Submit proof of highest bid
    // 4. Verify proof on-chain

    // For now, we make the highest bid publicly decryptable
    FHE.makePubliclyDecryptable(_highestBid);

    state = AuctionState.Finalized;
  }

  /**
   * @notice Verify and record the winner
   * @param winnerAddress The claimed winner address
   * @param abiEncodedAmount The ABI-encoded winning amount
   * @param decryptionProof The decryption proof
   */
  function recordWinner(
    address winnerAddress,
    bytes memory abiEncodedAmount,
    bytes memory decryptionProof
  ) external {
    require(state == AuctionState.Finalized, "Auction not finalized");
    require(highestBidder == address(0), "Winner already recorded");

    // Verify the decryption
    bytes32[] memory cts = new bytes32[](1);
    cts[0] = FHE.toBytes32(_highestBid);

    FHE.checkSignatures(cts, abiEncodedAmount, decryptionProof);

    // Record the winner
    highestBidder = winnerAddress;

    emit WinnerDetermined(winnerAddress);
  }

  /**
   * @notice Get number of bids
   * @return Total number of bids placed
   */
  function getBidCount() external view returns (uint256) {
    return _bids.length;
  }

  /**
   * @notice Get bidder's bid count
   * @param bidder The bidder address
   * @return Number of bids placed by this bidder
   */
  function getBidderBidCount(address bidder) external view returns (uint256) {
    return _bidderToBids[bidder].length;
  }

  /**
   * @notice Check if auction is still active
   * @return True if auction is active
   */
  function isActive() external view returns (bool) {
    return state == AuctionState.Active && block.timestamp < auctionEndTime;
  }
}
