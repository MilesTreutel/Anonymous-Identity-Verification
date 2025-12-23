# Access Control in FHEVM

## Overview

Access control in FHEVM determines who can:
1. **Access (use)** encrypted values in contract operations
2. **Decrypt** encrypted values to see plaintext results

## Permission Types

### 1. Contract Permission (FHE.allowThis)

Grants the contract itself permission to operate on an encrypted value:

```solidity
function processValue(externalEuint32 inputValue, bytes calldata inputProof) external {
    euint32 value = FHE.fromExternal(inputValue, inputProof);

    // Grant contract permission
    FHE.allowThis(value);

    // Now contract can use this value in operations
    euint32 result = FHE.add(value, FHE.asEuint32(10));
}
```

### 2. User Permission (FHE.allow)

Grants a specific address permission to decrypt an encrypted value:

```solidity
function storeUserValue(externalEuint32 inputValue, bytes calldata inputProof) external {
    euint32 value = FHE.fromExternal(inputValue, inputProof);
    FHE.allowThis(value);

    // Grant user permission to decrypt
    FHE.allow(value, msg.sender);

    // Store value
    userValues[msg.sender] = value;
}
```

### 3. Multi-Party Access

Grant multiple parties access to the same encrypted value:

```solidity
function grantMultipleAccess(address[] calldata users) external {
    euint32 value = FHE.asEuint32(100);
    FHE.allowThis(value);

    // Grant all users access
    for (uint256 i = 0; i < users.length; i++) {
        FHE.allow(value, users[i]);
    }
}
```

## Permission Lifecycle

### Input Stage
```
User encrypts value → Input proof created → Value sent to contract
```

### Processing Stage
```
FHE.fromExternal(value, proof) → value imported with temp permissions
↓
FHE.allowThis(value) → grant contract permanent permission
↓
Operations proceed → ephemeral permissions granted during operation
```

### Output Stage
```
Result created → ephemeral permission granted to contract
↓
FHE.allowThis(result) → grant contract permanent permission
↓
FHE.allow(result, user) → grant user decryption permission
```

## Common Patterns

### Pattern: User Decryption

User can decrypt their own value:

```solidity
mapping(address => euint32) private userSecrets;

function storeSecret(externalEuint32 secret, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(secret, proof);
    FHE.allowThis(value);
    FHE.allow(value, msg.sender);  // Only sender can decrypt
    userSecrets[msg.sender] = value;
}

function getMySecret() external view returns (euint32) {
    return userSecrets[msg.sender];
}
```

### Pattern: Public Decryption

Anyone can decrypt the result:

```solidity
function getPublicResult() external {
    euint32 result = FHE.add(a, b);
    FHE.allowThis(result);
    FHE.makePubliclyDecryptable(result);
}
```

### Pattern: Restricted Access

Only contract can use value, no one can decrypt:

```solidity
function secretComputation(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);
    // NO FHE.allow() called - only contract can decrypt

    euint32 result = FHE.mul(value, privateKey);
    FHE.allowThis(result);
    // Store result without granting user access
}
```

## FHE.allowTransient

Grants transient permissions (valid only during current transaction):

```solidity
function temporaryAccess(address user) external {
    euint32 value = FHE.asEuint32(100);
    FHE.allowThis(value);

    // Grant permission only for this transaction
    FHE.allowTransient(value, user);

    // User can decrypt during this transaction only
}
```

## Anti-Patterns

### ❌ Missing FHE.allowThis()

```solidity
// WRONG - contract can't use value
function processBadly(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    // Missing: FHE.allowThis(value);
    euint32 result = FHE.add(value, 10);  // FAILS!
}
```

### ❌ Missing User Permission

```solidity
// WRONG - user can't decrypt result
function storeBadly(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);
    // Missing: FHE.allow(value, msg.sender);
    storedValues[msg.sender] = value;  // User can't decrypt!
}
```

### ❌ Over-Permissive Access

```solidity
// RISKY - grants everyone access
function storeRisky(externalEuint32 input, bytes calldata proof) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);
    FHE.makePubliclyDecryptable(value);  // Anyone can decrypt!

    secretValues[msg.sender] = value;
}
```

## Best Practices

1. **Always grant FHE.allowThis()** before operating on a value
2. **Grant user permissions explicitly** - don't rely on defaults
3. **Use FHE.allowTransient()** for one-time permissions
4. **Make results publicly decryptable** only when necessary
5. **Document permission requirements** in contract comments
6. **Test permission scenarios** in your test suite

## Verification Checklist

- [ ] All operations have FHE.allowThis() granted
- [ ] User permissions match intended access patterns
- [ ] No sensitive values are publicly decryptable
- [ ] Temporary permissions use FHE.allowTransient()
- [ ] All permission paths are tested

## Next Steps

- Read [Input Proofs](input-proofs.md)
- Study [User Decryption](user-decryption.md)
- Explore [AnonymousIdentityVerification.sol](../contracts/anonymous-identity-verification.md)

## Further Resources

- [FHEVM Access Control Docs](https://docs.zama.ai/fhevm/concepts/access-control)
- [Security Best Practices](../best-practices/security.md)
- [Examples in Repository](../../examples/)
