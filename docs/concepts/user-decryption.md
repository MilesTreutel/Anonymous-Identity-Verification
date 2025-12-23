# User Decryption in FHEVM

## Overview

User decryption allows users to decrypt values that the contract has granted them permission to access. This is the primary way users interact with encrypted results from smart contracts.

## How User Decryption Works

### 1. Contract Grants Permission

```solidity
function processAndAllowDecryption(
    externalEuint32 input,
    bytes calldata proof
) external {
    euint32 value = FHE.fromExternal(input, proof);
    FHE.allowThis(value);

    // Perform computation
    euint32 result = FHE.add(value, FHE.asEuint32(100));

    // Grant user permission to decrypt result
    FHE.allowThis(result);
    FHE.allow(result, msg.sender);

    // Store result
    userResults[msg.sender] = result;
}
```

### 2. User Requests Decryption

```typescript
// User gets encrypted handle from contract
const encryptedHandle = await contract.userResults(userAddress);

// Request decryption from relayer
const decryptionRequest = {
    handle: encryptedHandle,
    contractAddress: contract.address,
    userAddress: userAddress
};

const decryptedValue = await decryptionService.decrypt(decryptionRequest);
console.log("Decrypted value:", decryptedValue);
```

## Permission Granting

### Grant User Access

```solidity
function grantUserAccess(address user) external {
    euint32 value = userSecrets[msg.sender];

    // Grant user permission to decrypt
    FHE.allow(value, user);

    emit AccessGranted(msg.sender, user);
}
```

### Grant to Caller

```solidity
function getMySecret(
    externalEuint32 inputProof,
    bytes calldata proof
) external returns (euint32) {
    euint32 secret = FHE.fromExternal(inputProof, proof);
    FHE.allowThis(secret);

    // Grant caller decryption permission
    FHE.allow(secret, msg.sender);

    return secret;
}
```

## Decryption Relayer

The decryption relayer is a service that:
1. Receives decryption requests from users
2. Verifies the user has permission to decrypt
3. Performs the actual FHE decryption
4. Returns the plaintext to the user

### Using Zama Relayer SDK

```typescript
import { TFheEvmJS } from "@zama-fhe/tfhe-js";
import { ZamaRelayerSdk } from "@zama-fhe/relayer-sdk";

// Initialize relayer
const relayerUrl = "https://relayer.zama.network";
const relayer = new ZamaRelayerSdk(relayerUrl);

// Request decryption
const decryptionRequest = {
    handle: encryptedHandle,
    contractAddress: contract.address,
    userAddress: userAddress
};

const decryptedValue = await relayer.decrypt(decryptionRequest);
```

## Multi-Party Decryption

Grant multiple users access to same value:

```solidity
function shareSecret(address[] calldata recipients) external {
    euint32 value = userSecrets[msg.sender];
    FHE.allowThis(value);

    // Grant all recipients access
    for (uint256 i = 0; i < recipients.length; i++) {
        FHE.allow(value, recipients[i]);
    }

    emit SecretShared(msg.sender, recipients);
}
```

## Conditional Decryption

Control who can decrypt based on conditions:

```solidity
function conditionalDecrypt(
    address recipient,
    bool hasPermission
) external {
    euint32 result = FHE.asEuint32(secretValue);
    FHE.allowThis(result);

    if (hasPermission) {
        FHE.allow(result, recipient);
    }

    userResults[recipient] = result;
}
```

## Time-Limited Decryption

Using FHE.allowTransient for temporary permissions:

```solidity
function getTemporaryAccess() external {
    euint32 value = FHE.asEuint32(100);
    FHE.allowThis(value);

    // User can decrypt only in this transaction
    FHE.allowTransient(value, msg.sender);

    return value;
}
```

## Common Patterns

### Pattern: User Balance Query

```solidity
mapping(address => euint32) private balances;

function getMyBalance() external view returns (euint32) {
    return balances[msg.sender];
}
```

User can decrypt their own balance:

```typescript
const encryptedBalance = await contract.getMyBalance();
const balance = await relayer.decrypt({
    handle: encryptedBalance,
    contractAddress: contract.address,
    userAddress: userAddress
});
```

### Pattern: Conditional Result Decryption

```solidity
function compareAndReturnResult(
    externalEuint32 inputA,
    externalEuint32 inputB,
    bytes calldata proof
) external returns (euint32) {
    euint32 a = FHE.fromExternal(inputA, proof);
    euint32 b = FHE.fromExternal(inputB, proof);

    FHE.allowThis(a);
    FHE.allowThis(b);

    // Compare and return larger value (encrypted)
    euint32 result = FHE.gt(a, b);

    FHE.allowThis(result);
    FHE.allow(result, msg.sender);

    return result;
}
```

## Decryption Errors

### ❌ Missing Permission

```solidity
// WRONG - user can't decrypt
function getSecretNoPerm() external {
    euint32 secret = FHE.asEuint32(42);
    FHE.allowThis(secret);
    // Missing: FHE.allow(secret, msg.sender);
    return secret;  // User can't decrypt this!
}
```

### ❌ Wrong Relayer

```typescript
// WRONG - relayer can't decrypt without valid proof
const decrypted = await wrongRelayer.decrypt({
    handle: encryptedValue,
    contractAddress: contract.address,
    userAddress: userAddress
    // Missing: proof that user has permission
});
```

## Verification Flow

```
1. User calls contract function
   ↓
2. Contract performs computation
   ↓
3. Contract grants FHE.allow(result, user)
   ↓
4. Contract returns encrypted handle
   ↓
5. User requests decryption from relayer
   ↓
6. Relayer verifies user has permission
   ↓
7. Relayer decrypts value
   ↓
8. Relayer returns plaintext to user
```

## Best Practices

1. **Always grant explicit permissions**
   ```solidity
   FHE.allowThis(value);
   FHE.allow(value, msg.sender);
   ```

2. **Match permissions to intent**
   - User decryption: Use `FHE.allow()`
   - Contract use only: Use only `FHE.allowThis()`
   - Public decryption: Use `FHE.makePubliclyDecryptable()`

3. **Use temporary permissions when appropriate**
   ```solidity
   FHE.allowTransient(value, user);  // One transaction only
   ```

4. **Document permission requirements**
   ```solidity
   /// @notice Returns decryptable balance for caller
   function getBalance() external view returns (euint32) {
       return balances[msg.sender];
   }
   ```

## Testing Decryption

```typescript
// Simulate user decryption in tests
async function testUserDecryption() {
    // Grant permission
    const tx = await contract.grantPermission(user.address);
    await tx.wait();

    // User decrypts value
    const encrypted = await contract.userValue(user.address);
    const decrypted = await relayer.decrypt({
        handle: encrypted,
        contractAddress: contract.address,
        userAddress: user.address
    });

    // Verify decrypted value
    expect(decrypted).to.equal(expectedValue);
}
```

## Next Steps

- Read [Public Decryption](public-decryption.md)
- Study [Access Control](access-control.md)
- Explore [UserDecryptionExample.sol](../../examples/UserDecryptionExample.sol)

## Further Resources

- [Zama Relayer SDK](https://github.com/zama-ai/fhevm-relayer-sdk)
- [FHEVM Decryption Docs](https://docs.zama.ai/fhevm/user-guide/decryption)
- [Examples in Repository](../../examples/)
