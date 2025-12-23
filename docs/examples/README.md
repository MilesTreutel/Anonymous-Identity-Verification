# FHEVM Examples

This directory contains comprehensive examples demonstrating FHEVM concepts and patterns.

## Example Categories

### Basic Examples

1. **FHECounter.sol**
   - Simple encrypted counter demonstrating basic FHE operations
   - Shows increment/decrement on encrypted values
   - Demonstrates permission granting and result decryption

2. **EncryptionExample.sol**
   - Single value encryption patterns
   - Multiple value encryption patterns
   - Input proof validation

3. **AccessControlExample.sol**
   - FHE.allow() and FHE.allowThis() usage
   - Role-based access control
   - Permission lifecycle

4. **UserDecryptionExample.sol**
   - User-specific decryption patterns
   - Multiple user access scenarios
   - Decryption permission management

5. **InputProofExample.sol**
   - Input proof validation
   - Secure value binding
   - Proof verification patterns

6. **AntiPatternsExample.sol**
   - Common mistakes and their solutions
   - Missing permissions patterns
   - Incorrect usage examples

### Arithmetic Operations

7. **ArithmeticOperationsExample.sol**
   - FHE.add() - Addition on encrypted values
   - FHE.sub() - Subtraction on encrypted values
   - FHE.mul() - Multiplication on encrypted values
   - Chained operations

### Comparison Operations

8. **ComparisonOperationsExample.sol**
   - FHE.eq() - Equality comparison
   - FHE.ne() - Not equal comparison
   - FHE.lt(), FHE.le() - Less than operations
   - FHE.gt(), FHE.ge() - Greater than operations
   - Returns encrypted boolean results

### Advanced Examples

9. **PublicDecryptionExample.sol**
   - FHE.makePubliclyDecryptable() usage
   - Public verification patterns
   - Decryption proof verification
   - Anyone can decrypt results

10. **HandlesExample.sol**
    - Understanding FHE handles
    - Handle lifecycle
    - Symbolic execution
    - Handle equality and comparison

11. **ConfidentialERC20.sol** (OpenZeppelin-inspired)
    - Confidential token balances
    - Encrypted transfer operations
    - Private balance management
    - Based on ERC7984 concepts

12. **BlindAuction.sol** (Advanced)
    - Encrypted bid storage
    - Confidential auction logic
    - Time-based state transitions
    - Winner determination without revealing bids

## How to Use Examples

### 1. Study Individual Contracts

Each example file is well-documented with comments explaining:
- What the contract does
- Why it's implemented that way
- Common patterns and best practices
- Potential pitfalls and solutions

```bash
# Read example contract
cat examples/FHECounter.sol

# Understand the pattern
# - How encrypted values are created
# - How permissions are granted
# - How results are made available
```

### 2. Run Tests

Each example has corresponding tests:

```bash
npm test -- test/examples/FHECounter.test.ts
```

### 3. Generate Standalone Repository

Use the automation tool to create a standalone example:

```bash
npm run create-example fhe-counter ./my-fhe-counter
cd my-fhe-counter
npm install
npm test
```

## Learning Path

### Beginner

1. Start with **FHECounter.sol** - understand basic structure
2. Read **EncryptionExample.sol** - learn value encryption
3. Study **AccessControlExample.sol** - understand permissions
4. Explore **UserDecryptionExample.sol** - learn decryption

### Intermediate

5. Study **InputProofExample.sol** - master input validation
6. Understand **ArithmeticOperationsExample.sol** - learn operations
7. Explore **ComparisonOperationsExample.sol** - encrypted conditions
8. Read **AntiPatternsExample.sol** - learn common mistakes

### Advanced

9. Study **HandlesExample.sol** - understand symbolic execution
10. Explore **PublicDecryptionExample.sol** - public verification
11. Build with **ConfidentialERC20.sol** - token patterns
12. Architect **BlindAuction.sol** - complex applications

## Contract Checklist

When implementing your own FHEVM contract, use these examples as references:

- [ ] **Input Handling**: See EncryptionExample.sol, InputProofExample.sol
- [ ] **Permissions**: See AccessControlExample.sol, UserDecryptionExample.sol
- [ ] **Arithmetic**: See ArithmeticOperationsExample.sol, FHECounter.sol
- [ ] **Comparisons**: See ComparisonOperationsExample.sol
- [ ] **Decryption**: See UserDecryptionExample.sol, PublicDecryptionExample.sol
- [ ] **Error Handling**: See AntiPatternsExample.sol
- [ ] **Events**: See all examples for event patterns
- [ ] **Testing**: Check test files for testing patterns

## Common Patterns

### Pattern: Accept Encrypted Input

```solidity
function setSecret(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);
    FHE.allow(value, msg.sender);
    userSecrets[msg.sender] = value;
}
```

### Pattern: Perform Computation

```solidity
function compute() external {
    euint32 a = userSecrets[msg.sender];
    euint32 result = FHE.add(a, FHE.asEuint32(10));
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);
}
```

### Pattern: Make Publicly Decryptable

```solidity
function getPublicResult() external {
    euint32 result = FHE.asEuint32(42);
    FHE.allowThis(result);
    FHE.makePubliclyDecryptable(result);
    emit PublicResult(result);
}
```

## Anti-Patterns to Avoid

❌ **Missing FHE.allowThis()**
```solidity
// WRONG
euint32 value = FHE.fromExternal(input, proof);
euint32 result = FHE.add(value, 10);  // Fails!
```

❌ **Missing User Permission**
```solidity
// WRONG
euint32 secret = FHE.fromExternal(input, proof);
FHE.allowThis(secret);
// Missing: FHE.allow(secret, msg.sender);
```

❌ **View Function with Encrypted Values**
```solidity
// WRONG
function getValue() external view returns (euint32) {
    // Can't return encrypted values from view functions!
    return encryptedValue;
}
```

## Testing Examples

All examples include comprehensive tests:

```bash
# Run all example tests
npm test -- test/examples/

# Run specific example test
npm test -- test/examples/FHECounter.test.ts

# Run with coverage
npm run coverage
```

## Deploying Examples

Deploy examples to testnet:

```bash
# Deploy to Sepolia
npm run deploy:sepolia

# Deploy specific example
npx hardhat run scripts/deploy.ts --network sepolia
```

## Further Reading

- [FHEVM Basics](../concepts/fhevm-basics.md)
- [Access Control](../concepts/access-control.md)
- [Input Proofs](../concepts/input-proofs.md)
- [User Decryption](../concepts/user-decryption.md)

## Need Help?

- Check example comments for detailed explanations
- Read corresponding concept documentation
- Review test cases for usage patterns
- Join [Zama Community](https://www.zama.ai/community)
- Ask on [GitHub Discussions](https://github.com/zama-ai/fhevm/discussions)

## Contributing

Want to add an example? Check [DEVELOPER_GUIDE.md](../../DEVELOPER_GUIDE.md) for guidelines.
