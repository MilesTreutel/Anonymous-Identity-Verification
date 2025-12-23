# Input Proofs in FHEVM

## What are Input Proofs?

Input proofs are zero-knowledge proofs that validate encrypted values are:
1. **Correctly encrypted** to the target contract
2. **Correctly bound** to the user who encrypted them
3. **Not tampered with** after encryption
4. **Properly formatted** for the FHEVM

## Why Input Proofs Matter

Without input proofs, users could:
- Send values encrypted to wrong contracts
- Send values encrypted by different users
- Modify ciphertexts in transit
- Use malformed encrypted data

Input proofs prevent these attacks.

## How Input Proofs Work

### 1. Client-Side Encryption

```typescript
// User encrypts value to send to contract
const fhevm = await initFhevmJs({ chainId: 11155111 });

// Create encrypted input bound to this contract and user
const encryptedInput = await fhevm.createEncryptedInput(
    contractAddress,      // Contract these values are for
    userAddress          // User encrypting the values
);

// Add encrypted values
encryptedInput.add32(secretValue);

// Get encrypted data and proof
const encrypted = encryptedInput.encrypt();
// encrypted.handles - the encrypted ciphertexts
// encrypted.inputProof - the zero-knowledge proof
```

### 2. Contract-Side Verification

```solidity
function receiveValue(
    externalEuint32 inputValue,    // The encrypted value
    bytes calldata inputProof       // The proof of correct encryption
) external {
    // FHE.fromExternal verifies the proof
    // If proof is invalid, transaction reverts
    euint32 value = FHE.fromExternal(inputValue, inputProof);

    FHE.allowThis(value);
    // Now we know value was correctly encrypted!
}
```

## Input Proof Validation

The proof validates:

```
Proof proves that:
├─ Value is encrypted with correct contract address
├─ Value is encrypted with correct user address
├─ Encryption is authentic (not modified)
├─ Value is properly formatted
└─ Signer authorized this encryption
```

## Understanding Input Structure

When creating encrypted input with multiple values:

```typescript
const encryptedInput = await fhevm.createEncryptedInput(
    contractAddress,
    userAddress
);

encryptedInput.add32(value1);  // Handle 0
encryptedInput.add32(value2);  // Handle 1
encryptedInput.add32(value3);  // Handle 2

const encrypted = encryptedInput.encrypt();
// encrypted.handles[0] = ciphertext for value1
// encrypted.handles[1] = ciphertext for value2
// encrypted.handles[2] = ciphertext for value3
// encrypted.inputProof = proof for all handles
```

## Contract Usage Patterns

### Single Value

```solidity
function setSingleValue(
    externalEuint32 encryptedValue,
    bytes calldata inputProof
) external {
    euint32 value = FHE.fromExternal(encryptedValue, inputProof);
    FHE.allowThis(value);
    userValue[msg.sender] = value;
}
```

### Multiple Values

```solidity
function setMultipleValues(
    externalEuint32 valueA,
    externalEuint32 valueB,
    bytes calldata inputProof
) external {
    euint32 a = FHE.fromExternal(valueA, inputProof);
    euint32 b = FHE.fromExternal(valueB, inputProof);

    FHE.allowThis(a);
    FHE.allowThis(b);

    userA[msg.sender] = a;
    userB[msg.sender] = b;
}
```

## Common Errors

### ❌ Wrong Contract Address

```typescript
// WRONG - encrypted to wrong contract
const encrypted = await fhevm.createEncryptedInput(
    wrongContractAddress,  // Oops!
    userAddress
).encrypt();

// This will fail when sent to actual contract
contract.setValue(encrypted.handles[0], encrypted.inputProof);
// Transaction reverts - proof doesn't match contract
```

### ❌ Wrong User Address

```typescript
// WRONG - encrypted by different user
const encrypted = await fhevm.createEncryptedInput(
    contractAddress,
    wrongUserAddress      // Oops!
).encrypt();

// This will fail - proof doesn't match signer
```

### ❌ Reusing Proof with Different Values

```typescript
// WRONG - proof is for specific values
const encrypted1 = encryptedInput.encrypt();
const encrypted2 = encryptedInput.encrypt();

// Can't mix proofs with different values!
contract.setValue(
    encrypted1.handles[0],
    encrypted2.inputProof  // WRONG PROOF!
);
```

## Best Practices

### 1. Always Validate in Contract

```solidity
// Always use FHE.fromExternal - it validates the proof
euint32 value = FHE.fromExternal(inputValue, inputProof);

// If proof is invalid, fromExternal reverts
```

### 2. Use Correct Binding

```typescript
// Always bind to correct addresses
const encrypted = await fhevm.createEncryptedInput(
    tokenContract.address,   // Exact contract address
    userWallet.address       // User's actual address
).encrypt();
```

### 3. Handle Proof Storage

```typescript
// Proofs are needed for on-chain verification
const proof = encrypted.inputProof;  // Keep this!
const handles = encrypted.handles;   // Send these to contract

// Transaction must include both
await contract.setValue(handles[0], proof);
```

### 4. Multiple Values

```typescript
// When using multiple values, proof covers all
const input = fhevm.createEncryptedInput(contract, user);
input.add32(value1);
input.add32(value2);
input.add32(value3);
const encrypted = input.encrypt();

// One proof validates all three values
await contract.setValues(
    encrypted.handles[0],
    encrypted.handles[1],
    encrypted.handles[2],
    encrypted.inputProof    // Validates all three
);
```

## Proof Verification Checklist

- [ ] Encrypted to correct contract address
- [ ] Encrypted by correct user address
- [ ] Proof matches input values
- [ ] Proof included in transaction
- [ ] Contract uses FHE.fromExternal()
- [ ] All required values included

## Error Handling

```typescript
try {
    // Attempt to send encrypted input with proof
    const tx = await contract.setValue(
        encryptedValue,
        inputProof
    );
    await tx.wait();
} catch (error) {
    if (error.message.includes("Invalid proof")) {
        // Proof doesn't match contract or user
        console.error("Proof validation failed - check addresses");
    }
}
```

## Next Steps

- Read [Access Control](access-control.md)
- Study [User Decryption](user-decryption.md)
- Explore [InputProofExample.sol](../../examples/InputProofExample.sol)

## Further Resources

- [FHEVM Input Proofs Docs](https://docs.zama.ai/fhevm/concepts/input-proofs)
- [Example Implementation](../../examples/InputProofExample.sol)
- [Security Best Practices](../best-practices/security.md)
