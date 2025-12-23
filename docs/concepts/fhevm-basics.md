# FHEVM Basics

## What is FHEVM?

FHEVM (Fully Homomorphic Encryption Virtual Machine) is a blockchain-based confidential computation platform by Zama that enables:

- **Encrypted Data**: Store and process data while encrypted on-chain
- **Confidential Computation**: Perform calculations on encrypted values without decryption
- **Privacy-Preserving Smart Contracts**: Build dApps where sensitive data remains encrypted

## How It Works

### 1. Encryption

Values are encrypted client-side before being sent to the blockchain:

```solidity
// Create encrypted input
const enc = await fhevm.createEncryptedInput(contractAddress, userAddress);
const encryptedValue = enc.add32(secretValue).encrypt();
```

### 2. Smart Contract Processing

The contract receives encrypted values and processes them:

```solidity
function processValue(externalEuint32 inputValue, bytes calldata inputProof) external {
    // Decrypt from external input
    euint32 value = FHE.fromExternal(inputValue, inputProof);

    // Grant permissions
    FHE.allowThis(value);

    // Perform operations on encrypted value
    euint32 result = FHE.add(value, FHE.asEuint32(10));
}
```

### 3. Decryption

Only authorized parties can decrypt results:

```solidity
// Make decryptable by specific user
FHE.allow(result, userAddress);

// Or make publicly decryptable
FHE.makePubliclyDecryptable(result);
```

## Key Concepts

### Encrypted Types

- `euint8`, `euint16`, `euint32`, `euint64` - Unsigned integers
- `ebool` - Boolean values
- `eaddress` - Encrypted addresses

### Permissions System

**FHE.allowThis()** - Grant contract permission to access a value

**FHE.allow()** - Grant specific address permission to decrypt a value

```solidity
FHE.allowThis(encryptedValue);        // Contract can use it
FHE.allow(encryptedValue, userAddr);  // User can decrypt it
```

### Input Proofs

Input proofs validate that encrypted values are correctly bound to the contract and user:

```solidity
// Proof ensures:
// - Value is actually encrypted to this contract
// - Proof is signed by the original encryptor
// - No manipulation occurred
euint32 value = FHE.fromExternal(inputValue, inputProof);
```

## Supported Operations

### Arithmetic
- `FHE.add(a, b)` - Addition
- `FHE.sub(a, b)` - Subtraction
- `FHE.mul(a, b)` - Multiplication
- `FHE.div(a, b)` - Division (encrypted divisor not supported)

### Comparison
- `FHE.eq(a, b)` - Equal
- `FHE.ne(a, b)` - Not equal
- `FHE.lt(a, b)` - Less than
- `FHE.le(a, b)` - Less than or equal
- `FHE.gt(a, b)` - Greater than
- `FHE.ge(a, b)` - Greater than or equal

### Bitwise
- `FHE.and(a, b)` - Bitwise AND
- `FHE.or(a, b)` - Bitwise OR
- `FHE.xor(a, b)` - Bitwise XOR

### Random
- `FHE.randEuint8()` - Random encrypted uint8
- `FHE.randEuint32()` - Random encrypted uint32
- `FHE.randEbool()` - Random encrypted bool

## Performance Considerations

1. **Encrypted operations are slower** than plaintext operations
2. **Multiplication is more expensive** than addition
3. **Division by encrypted values is not supported**
4. **Comparison operations produce encrypted results**

## Common Patterns

### Pattern: Encrypted Balance

```solidity
mapping(address => euint32) private balances;

function getBalance(address user) external view returns (euint32) {
    return balances[user];
}
```

### Pattern: Conditional Execution

```solidity
// Can't use encrypted values in if statements
// Instead, use conditional FHE operations
ebool isGreaterThan = FHE.gt(a, b);

// Or restructure logic to work with encrypted results
euint32 result = FHE.cmux(isGreaterThan, valueA, valueB);
```

### Pattern: Secure Computation

```solidity
function secureCompute(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);

    // Perform computation
    euint32 result = FHE.add(value, privateKey);

    // Allow user to decrypt
    FHE.allow(result, msg.sender);
}
```

## Security Properties

- **Semantic Security**: Ciphertexts reveal no information about plaintexts
- **Homomorphic Property**: Can compute on encrypted data
- **Binding**: Values are cryptographically bound to contract and user
- **Authenticity**: Input proofs prevent tampering

## Next Steps

- Read [Access Control](access-control.md)
- Explore [Input Proofs](input-proofs.md)
- Study example contracts in the `/examples` directory

## Further Reading

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Homomorphic Encryption Explained](https://www.zama.ai/post/homomorphic-encryption)
- [Academic Papers on FHE](https://www.zama.ai/community)
