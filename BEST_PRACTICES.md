# Best Practices: FHEVM Development Guide

## Table of Contents
1. [Security Patterns](#security-patterns)
2. [Privacy Design](#privacy-design)
3. [Code Organization](#code-organization)
4. [Testing Strategies](#testing-strategies)
5. [Gas Optimization](#gas-optimization)
6. [Error Handling](#error-handling)
7. [Documentation](#documentation)
8. [Common Pitfalls](#common-pitfalls)

## Security Patterns

### 1. Input Validation

**Best Practice: Validate at System Boundaries**

```solidity
// ✅ CORRECT: Validate user input
function registerIdentityProof(uint32 credential, uint8 score) external {
    require(score >= MIN_IDENTITY_SCORE, "Score too low");
    require(credential > 0, "Invalid credential");
    // ... rest of function
}

// ❌ WRONG: No validation
function registerIdentityProof(uint32 credential, uint8 score) external {
    identityProofs[msg.sender] = IdentityProof(...);
}
```

**Validation Checklist:**
- [ ] Check for zero values
- [ ] Verify bounds (min/max)
- [ ] Validate state prerequisites
- [ ] Confirm caller authorization
- [ ] Test boundary conditions

### 2. Access Control

**Best Practice: Use Modifiers for Authorization**

```solidity
// ✅ CORRECT: Use modifiers
modifier onlyOwner() {
    require(msg.sender == owner, "Not authorized");
    _;
}

function authorizeVerifier(address verifier) external onlyOwner {
    authorizedVerifiers[verifier] = true;
}

// ❌ WRONG: Repeated checks
function authorizeVerifier(address verifier) external {
    require(msg.sender == owner, "Not authorized");
    authorizedVerifiers[verifier] = true;
}

function revokeVerifier(address verifier) external {
    require(msg.sender == owner, "Not authorized");
    authorizedVerifiers[verifier] = false;
}
```

**Access Control Guidelines:**
1. Define clear roles
2. Use modifiers consistently
3. Implement checks-effects-interactions
4. Log authorization changes
5. Regular access audits

### 3. State Consistency

**Best Practice: Maintain Invariants**

```solidity
// ✅ CORRECT: Check state before operations
modifier onlyActiveProof(address user) {
    require(identityProofs[user].isActive, "No active proof");
    require(identityProofs[user].expiryTime > block.timestamp, "Proof expired");
    _;
}

function requestVerification() external onlyActiveProof(msg.sender) {
    require(!identityProofs[msg.sender].isVerified, "Already verified");
    // ... safe to proceed
}

// ❌ WRONG: Incomplete state validation
function requestVerification() external {
    // Doesn't check if proof is active or expired
    verificationRequests[requestId] = VerificationRequest(...);
}
```

**State Consistency Checklist:**
- [ ] All prerequisites verified
- [ ] Atomic state updates
- [ ] Consistent event emission
- [ ] No partial state changes
- [ ] Rollback capability on errors

### 4. Reentrancy Safety

**Best Practice: Checks-Effects-Interactions Pattern**

```solidity
// ✅ CORRECT: Update state before interactions
function submitVerificationProof(uint32 requestId, uint32 proofData) external {
    VerificationRequest storage request = verificationRequests[requestId];

    // 1. Checks
    require(request.requester == msg.sender, "Not your request");
    require(!request.isCompleted, "Already completed");

    // 2. Effects
    request.submittedProof = FHE.asEuint32(proofData);

    // 3. Interactions
    FHE.requestDecryption(...);
}

// ❌ WRONG: Interaction before state update
function submitVerificationProof(uint32 requestId, uint32 proofData) external {
    FHE.requestDecryption(...);  // Vulnerable to reentrancy
    verificationRequests[requestId].submittedProof = FHE.asEuint32(proofData);
}
```

## Privacy Design

### 1. Encrypted Data Types

**Best Practice: Use Encrypted Types for Sensitive Data**

```solidity
// ✅ CORRECT: Sensitive data encrypted
struct IdentityProof {
    euint32 encryptedCredential;  // ✅ Encrypted
    euint8 identityScore;         // ✅ Encrypted
    bool isVerified;              // Public OK
    uint256 timestamp;            // Public OK
}

// ❌ WRONG: Plaintext storage of sensitive data
struct IdentityProof {
    uint32 credential;            // ❌ Exposed!
    uint8 score;                  // ❌ Exposed!
    bool isVerified;
    uint256 timestamp;
}
```

**Guidelines:**
- Encrypt all sensitive identifiers
- Keep status and metadata public
- Use euint types for computation
- Document sensitivity levels

### 2. Access Control for Encrypted Values

**Best Practice: Grant Access Explicitly**

```solidity
// ✅ CORRECT: Grant appropriate access
euint32 encryptedCredential = FHE.asEuint32(credential);

// Contract-level access
FHE.allowThis(encryptedCredential);

// User-level access
FHE.allow(encryptedCredential, msg.sender);

// ❌ WRONG: No access granted
euint32 encryptedCredential = FHE.asEuint32(credential);
// Missing: FHE.allowThis() and FHE.allow()
```

**Access Granting Pattern:**
```solidity
// For contract-internal use
FHE.allowThis(encryptedValue);

// For user decryption
FHE.allow(encryptedValue, userAddress);

// For multiple users
for (uint i = 0; i < users.length; i++) {
    FHE.allow(encryptedValue, users[i]);
}
```

### 3. Mixing Public and Private Data

**Best Practice: Strategic Data Layering**

```solidity
// ✅ CORRECT: Minimal public data
struct VerificationRequest {
    address requester;              // Public: needed for routing
    euint32 encryptedChallenge;     // Private: the actual challenge
    euint32 submittedProof;         // Private: user's proof
    bool isCompleted;               // Public: status only
    bool isApproved;                // Public: result only
    uint256 requestTime;            // Public: for expiry checks
    uint256 challengeExpiryTime;    // Public: for time checks
}

// ❌ WRONG: Unnecessary public data
struct VerificationRequest {
    address requester;
    euint32 encryptedChallenge;
    euint32 submittedProof;
    uint32 challenge;               // ❌ Plaintext challenge!
    uint32 proof;                   // ❌ Plaintext proof!
    bool isCompleted;
    bool isApproved;
    // ... sensitive data exposed
}
```

### 4. Time-Based Privacy

**Best Practice: Use Expiry for Privacy Windowing**

```solidity
// ✅ CORRECT: Automatic expiry
uint256 constant CHALLENGE_VALIDITY = 1 hours;

function requestVerification() external returns (uint32 requestId) {
    verificationRequests[requestId].challengeExpiryTime =
        block.timestamp + CHALLENGE_VALIDITY;
}

// Enforce expiry
function submitVerificationProof(uint32 requestId, uint32 proofData) external {
    require(block.timestamp <= request.challengeExpiryTime, "Expired");
    // ... proceed
}

// ❌ WRONG: No time-based expiry
function requestVerification() external returns (uint32 requestId) {
    verificationRequests[requestId].challengeExpiryTime = block.timestamp;
    // Challenge never expires!
}
```

## Code Organization

### 1. Contract Structure

**Best Practice: Logical Organization**

```solidity
pragma solidity ^0.8.24;

import { ... };

/**
 * @title AnonymousIdentityVerification
 * @dev Privacy-preserving identity verification using FHEVM
 */
contract AnonymousIdentityVerification is SepoliaConfig {
    // 1. State variables
    uint256 constant PROOF_VALIDITY = 30 days;

    // 2. Struct definitions
    struct IdentityProof { ... }

    // 3. Mappings
    mapping(address => IdentityProof) public identityProofs;

    // 4. Events
    event IdentityProofRegistered(address indexed user, uint256 timestamp);

    // 5. Modifiers
    modifier onlyOwner() { ... }

    // 6. Constructor
    constructor() { ... }

    // 7. Public/External functions
    function registerIdentityProof(...) external { ... }

    // 8. View functions
    function getIdentityStatus(...) external view { ... }

    // 9. Private functions
    function _validateProof(...) private pure { ... }
}
```

### 2. Naming Conventions

**Best Practice: Clear, Descriptive Names**

```solidity
// ✅ CORRECT: Descriptive names
address public owner;                    // Clear ownership
euint32 encryptedCredential;             // Indicates encrypted
bool isVerified;                         // Boolean is verb
uint256 expiryTime;                      // Time-related naming
mapping(address => IdentityProof) identityProofs;  // Plural for collections

function registerIdentityProof(...) { } // Action verbs
function getIdentityStatus(...) { }     // Query prefix
function _validateProof(...) { }        // Private: underscore

// ❌ WRONG: Unclear names
address a;                               // Single letter
euint32 cred;                            // Abbreviated
bool v;                                  // Not descriptive
uint256 time;                            // Too generic
mapping(address => IP) ip;               // Unclear abbreviation

function reg(...) { }                    // Not descriptive
function getId(...) { }                  // Non-standard pattern
function checkProof(...) { }             // Not private indicator
```

### 3. Comment Standards

**Best Practice: JSDoc-Style Comments**

```solidity
// ✅ CORRECT: Comprehensive comments
/**
 * @dev Registers an encrypted identity proof for the caller
 * @param credential The user's identity credential (1-based index)
 * @param score The identity score (minimum 75 required)
 * @notice Requires credential > 0 and score >= MIN_IDENTITY_SCORE
 * @notice Proof valid for 30 days from registration
 */
function registerIdentityProof(uint32 credential, uint8 score) external {
    require(score >= MIN_IDENTITY_SCORE, "Score too low");
    // ... rest of function
}

// ❌ WRONG: Unclear or missing comments
function registerIdentityProof(uint32 credential, uint8 score) external {
    // TODO: check score
    // fix later
    identityProofs[msg.sender] = IdentityProof(...);
}
```

## Testing Strategies

### 1. Test Structure

**Best Practice: Organized Test Suites**

```javascript
// ✅ CORRECT: Organized test structure
describe("AnonymousIdentityVerification", function () {
  // Setup
  let contract, owner, user1, user2;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const factory = await ethers.getContractFactory("AnonymousIdentityVerification");
    contract = await factory.deploy();
  });

  describe("Registration", function () {
    it("should register valid identity proof", async function () {
      await contract.connect(user1).registerIdentityProof(12345, 80);
      const [isActive] = await contract.getIdentityStatus(user1.address);
      expect(isActive).to.be.true;
    });

    it("should reject low identity score", async function () {
      await expect(
        contract.connect(user1).registerIdentityProof(12345, 70)
      ).to.be.revertedWith("Score too low");
    });
  });

  describe("Verification", function () {
    // ... more tests
  });
});
```

### 2. Test Coverage

**Best Practice: Comprehensive Coverage**

```javascript
// Cover these scenarios:
// ✅ Happy path: Valid operations
// ✅ Edge cases: Boundaries, empty data
// ✅ Error cases: Invalid inputs
// ✅ Authorization: Access control
// ✅ State changes: Consistent transitions
// ✅ Event emission: Correct logging
// ✅ Integration: Multi-function workflows
```

### 3. Gas Testing

**Best Practice: Monitor Gas Usage**

```bash
# Run tests with gas reporting
REPORT_GAS=true npm run test

# Output shows gas per function:
# Function              calls  avg  [min]  [max]
# registerIdentityProof  10    165234 152000 178000
# requestVerification    8     215000 200000 250000
```

## Gas Optimization

### 1. Storage Optimization

**Best Practice: Efficient Packing**

```solidity
// ✅ CORRECT: Grouped similar types
struct IdentityProof {
    euint32 encryptedCredential;    // Encrypted type (expensive)
    euint8 identityScore;           // Encrypted type (expensive)
    bool isVerified;                // 1 byte
    bool isActive;                  // 1 byte (could share with bool above)
    uint256 timestamp;              // 32 bytes
    uint256 expiryTime;             // 32 bytes
}

// ❌ WRONG: Inefficient ordering
struct IdentityProof {
    bool isVerified;                // 1 byte wasted space
    euint32 encryptedCredential;    // 32+ bytes
    bool isActive;                  // 1 byte wasted space
    euint8 identityScore;           // 1 byte
    uint256 timestamp;              // 32 bytes
    uint256 expiryTime;             // 32 bytes
}
```

### 2. Function Optimization

**Best Practice: Minimize Storage Operations**

```solidity
// ✅ CORRECT: Single write per operation
function registerIdentityProof(uint32 credential, uint8 score) external {
    identityProofs[msg.sender] = IdentityProof({
        encryptedCredential: FHE.asEuint32(credential),
        identityScore: FHE.asEuint8(score),
        isVerified: false,
        isActive: true,
        timestamp: block.timestamp,
        expiryTime: block.timestamp + PROOF_VALIDITY_PERIOD
    });
    // Single storage write
}

// ❌ WRONG: Multiple writes
function registerIdentityProof(uint32 credential, uint8 score) external {
    identityProofs[msg.sender].encryptedCredential = FHE.asEuint32(credential);
    identityProofs[msg.sender].identityScore = FHE.asEuint8(score);
    identityProofs[msg.sender].isVerified = false;
    identityProofs[msg.sender].isActive = true;
    identityProofs[msg.sender].timestamp = block.timestamp;
    // Multiple storage writes (expensive!)
}
```

### 3. View Function Optimization

**Best Practice: Use View Functions Efficiently**

```solidity
// ✅ CORRECT: Direct mapping lookup
function getIdentityStatus(address user) external view returns (...) {
    IdentityProof storage proof = identityProofs[user];
    return (proof.isActive, proof.isVerified, proof.expiryTime, proof.timestamp);
    // O(1) read
}

// ❌ WRONG: Unnecessary computation
function getIdentityStatus(address user) external view returns (...) {
    IdentityProof storage proof = identityProofs[user];

    // Unnecessary processing
    for (uint i = 0; i < 100; i++) {
        // ... waste computation
    }

    return (...);
}
```

## Error Handling

### 1. Clear Error Messages

**Best Practice: Descriptive Revert Messages**

```solidity
// ✅ CORRECT: Clear error messages
require(score >= MIN_IDENTITY_SCORE, "Identity score must be at least 75");
require(credential > 0, "Credential cannot be zero");
require(identityProofs[user].isActive, "No active identity proof for user");
require(block.timestamp <= request.challengeExpiryTime, "Verification challenge expired");

// ❌ WRONG: Vague messages
require(score >= 75, "Invalid");
require(credential > 0, "Bad");
require(identityProofs[user].isActive, "Error");
require(block.timestamp <= request.challengeExpiryTime, "Expired");
```

### 2. Custom Errors

**Best Practice: Use Custom Errors for Gas Efficiency**

```solidity
// ✅ CORRECT: Custom errors (saves gas)
error ScoreTooLow(uint8 score, uint8 minimum);
error InvalidCredential(uint32 credential);
error NoActiveProof(address user);

function registerIdentityProof(uint32 credential, uint8 score) external {
    if (score < MIN_IDENTITY_SCORE) revert ScoreTooLow(score, MIN_IDENTITY_SCORE);
    if (credential == 0) revert InvalidCredential(credential);
    // ... rest of function
}

// ❌ WRONG: String error messages (more gas)
require(score >= MIN_IDENTITY_SCORE, "Score too low");
require(credential > 0, "Invalid credential");
```

## Documentation

### 1. README Structure

**Best Practice: Comprehensive README**

```markdown
# Project Name
Brief description

## Features
- Feature 1
- Feature 2

## Installation
Step-by-step setup

## Usage
How to use

## Testing
How to run tests

## Deployment
Deployment instructions

## Contributing
Contribution guidelines
```

### 2. Code Comments

**Best Practice: Document "Why" Not "What"**

```solidity
// ✅ CORRECT: Explain the why
// Tolerance of 1% prevents precision issues with modulo arithmetic
uint32 tolerance = expectedProof / 100;

// ❌ WRONG: Just describes what you see
// Create a tolerance
uint32 tolerance = expectedProof / 100;
```

## Common Pitfalls

### 1. Forgetting Access Grants

```solidity
// ❌ PITFALL: Encrypted value without access
euint32 secret = FHE.asEuint32(value);
// User can't decrypt this!

// ✅ SOLUTION: Grant appropriate access
euint32 secret = FHE.asEuint32(value);
FHE.allowThis(secret);        // Contract can use it
FHE.allow(secret, msg.sender); // User can decrypt it
```

### 2. Mixing Encrypted and Plain Operations

```solidity
// ❌ PITFALL: Can't compare encrypted with plain
if (encryptedAge > 18) { ... }  // Compilation error

// ✅ SOLUTION: Use FHE operations
ebool isAdult = FHE.gt(encryptedAge, FHE.asEuint8(18));
```

### 3. Incorrect View Function Usage

```solidity
// ❌ PITFALL: Returning encrypted value from view
function getCredential() external view returns (euint32) {
    return identityProofs[msg.sender].encryptedCredential;
    // Can't return encrypted from view!
}

// ✅ SOLUTION: Return only what's accessible
function getIdentityStatus() external view returns (bool, bool, uint256, uint256) {
    IdentityProof storage proof = identityProofs[msg.sender];
    return (proof.isActive, proof.isVerified, proof.expiryTime, proof.timestamp);
}
```

### 4. Not Validating Inputs

```solidity
// ❌ PITFALL: No input validation
function registerIdentityProof(uint32 credential, uint8 score) external {
    identityProofs[msg.sender] = IdentityProof(...);
    // What if score is 0? What if credential is 0?
}

// ✅ SOLUTION: Validate all inputs
function registerIdentityProof(uint32 credential, uint8 score) external {
    require(score >= MIN_IDENTITY_SCORE, "Score too low");
    require(credential > 0, "Invalid credential");
    identityProofs[msg.sender] = IdentityProof(...);
}
```

### 5. Insufficient Rate Limiting

```solidity
// ❌ PITFALL: No rate limiting
function requestVerification() external {
    // User can spam unlimited requests!
    verificationRequests[totalVerifications++] = VerificationRequest(...);
}

// ✅ SOLUTION: Implement rate limiting
function requestVerification() external {
    require(userRequestCounts[msg.sender] < MAX_REQUESTS_PER_USER, "Limit exceeded");
    userRequestCounts[msg.sender]++;
    verificationRequests[totalVerifications++] = VerificationRequest(...);
}
```

## Conclusion

These best practices ensure:
- **Secure**: Protected against common vulnerabilities
- **Private**: Sensitive data stays encrypted
- **Efficient**: Optimized gas usage
- **Maintainable**: Clean, documented code
- **Testable**: Comprehensive test coverage

Always prioritize security and privacy over premature optimization.

---

**Best Practices Guide Version**: 1.0
**Last Updated**: December 2025
**Status**: Production Ready
