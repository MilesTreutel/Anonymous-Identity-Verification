# Deployment Guide: Anonymous Identity Verification

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Local Development Setup](#local-development-setup)
3. [Contract Compilation](#contract-compilation)
4. [Testing](#testing)
5. [Sepolia Testnet Deployment](#sepolia-testnet-deployment)
6. [Production Considerations](#production-considerations)
7. [Verification and Monitoring](#verification-and-monitoring)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- **Node.js**: v16.0.0 or higher
- **npm**: v8.0.0 or higher (or yarn)
- **Git**: For version control
- **Memory**: Minimum 2GB RAM
- **Disk Space**: Minimum 500MB available

### Knowledge Requirements
- Basic Solidity understanding
- JavaScript/TypeScript familiarity
- Ethereum concepts (gas, transactions, wallet)
- MetaMask or Web3 wallet usage

### Accounts and Keys

1. **MetaMask Wallet**
   - Create account at https://metamask.io
   - Add Sepolia testnet to network list
   - Fund testnet account with test ETH

2. **Infura Account** (for RPC provider)
   - Sign up at https://infura.io
   - Create project in Sepolia network
   - Obtain Project ID

3. **Private Key Management**
   - Export from MetaMask (never share)
   - Store securely in `.env` file
   - Use environment variables only

### Test ETH Acquisition

Obtain Sepolia test ETH from faucets:
- **Infura Faucet**: https://www.infura.io/faucet/sepolia
- **Quicknode**: https://faucet.quicknode.com/ethereum/sepolia
- **Alchemy**: https://sepoliafaucet.com/

## Local Development Setup

### Step 1: Clone Repository

```bash
# Clone the project
git clone https://github.com/YourUsername/AnonymousIdentityVerification.git
cd AnonymousIdentityVerification

# Verify directory structure
ls -la
```

Expected structure:
```
AnonymousIdentityVerification/
├── contracts/
├── test/
├── scripts/
├── frontend/
├── hardhat.config.js
├── package.json
└── README.md
```

### Step 2: Install Dependencies

```bash
# Install npm packages
npm install

# Verify installation
npm list

# Expected core packages:
# - hardhat: ^2.19.0
# - @nomicfoundation/hardhat-toolbox: ^4.0.0
# - @fhevm/solidity: ^0.4.0
```

### Step 3: Configure Environment

Create `.env` file in project root:

```bash
# Copy template
cp .env.example .env

# Edit .env with your values
nano .env
```

**.env File Template:**
```env
# Wallet Configuration
PRIVATE_KEY=your_private_key_here

# RPC Provider Configuration
INFURA_API_KEY=your_infura_project_id

# Network Configuration
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY

# Optional: Etherscan for verification
ETHERSCAN_API_KEY=your_etherscan_key

# Optional: Contract addresses
DEPLOYED_CONTRACT_ADDRESS=0x...
```

**Security Notes:**
- Never commit `.env` file
- Add to `.gitignore`
- Rotate keys periodically
- Use read-only test accounts when possible

### Step 4: Verify Setup

```bash
# Test hardhat installation
npx hardhat --version

# Test dependencies
npm run test -- --no-compile

# Check compilation
npm run compile
```

## Contract Compilation

### Compilation Process

```bash
# Compile all contracts
npm run compile

# Clean and recompile
npx hardhat clean
npm run compile

# Compile with verbose output
npx hardhat compile --verbose
```

### Expected Compilation Output

```
Compiling 1 file with 0.8.24
Compilation successful!

artifacts/
├── AnonymousIdentityVerification.sol/
│   └── AnonymousIdentityVerification.json
└── ...
```

### Troubleshooting Compilation

**Error: Missing imports**
```bash
# Solution: Update package.json
npm install --save-dev @fhevm/solidity@latest
npm run compile
```

**Error: Version mismatch**
```bash
# Check current solidity version
npm run compile -- --verbose

# Update hardhat.config.js with correct version
```

## Testing

### Running Test Suite

```bash
# Run all tests
npm run test

# Run specific test file
npx hardhat test test/AnonymousIdentityVerification.test.js

# Run with gas reporting
REPORT_GAS=true npm run test

# Run with detailed output
npx hardhat test --verbose
```

### Test Coverage

```bash
# Install coverage plugin
npm install --save-dev solidity-coverage

# Generate coverage report
npx hardhat coverage

# View coverage in browser
open coverage/index.html
```

### Test Scenarios Included

1. **Registration Tests**
   - Valid credential registration
   - Invalid credential rejection
   - Low score rejection
   - Duplicate registration handling

2. **Verification Tests**
   - Request generation
   - Challenge creation
   - Proof submission
   - Validation logic

3. **Access Control Tests**
   - Owner-only function enforcement
   - Verifier authorization
   - User permission validation

4. **Edge Cases**
   - Expired proof handling
   - Rate limit enforcement
   - Invalid state transitions
   - Empty data handling

### Example Test Output

```
AnonymousIdentityVerification
  ✓ Should register identity proof (45ms)
  ✓ Should reject low identity score (12ms)
  ✓ Should request verification (67ms)
  ✓ Should submit proof (89ms)
  ✓ Should validate proof correctly (34ms)
  ✓ Should enforce rate limiting (23ms)
  ✓ Should handle expired proofs (15ms)
  ✓ Should manage verifier permissions (28ms)

8 passing (1.2s)
```

## Sepolia Testnet Deployment

### Pre-Deployment Checklist

- [ ] All tests passing locally
- [ ] Coverage acceptable (>80%)
- [ ] Code reviewed
- [ ] No hardcoded values
- [ ] Sufficient test ETH in wallet
- [ ] Private key configured in .env
- [ ] Contract verified in plan
- [ ] Documentation updated

### Deployment Script

**scripts/deploy.js:**
```javascript
async function main() {
  console.log("Deploying Anonymous Identity Verification...");

  const AnonymousIdentityVerification =
    await ethers.getContractFactory("AnonymousIdentityVerification");

  const contract =
    await AnonymousIdentityVerification.deploy();

  await contract.deployed();

  console.log("✅ Contract deployed to:", contract.address);

  // Save contract address
  const fs = require("fs");
  fs.writeFileSync(
    "deployed_contract",
    contract.address
  );

  // Wait for confirmation blocks
  console.log("Waiting for confirmations...");
  await contract.deployTransaction.wait(5);

  console.log("✅ Deployment confirmed!");
  return contract.address;
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

### Deployment Command

```bash
# Deploy to Sepolia testnet
npm run deploy:sepolia

# Output example:
# Deploying Anonymous Identity Verification...
# ✅ Contract deployed to: 0x813F34aa27F893C45f419dd9d32561a2639A8E15
# Waiting for confirmations...
# ✅ Deployment confirmed!
```

### Manual Deployment Alternative

```bash
# If deploy script fails
npx hardhat run scripts/deploy.js --network sepolia

# Verify with etherscan
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

## Post-Deployment Steps

### 1. Verify Contract Source

```bash
# Option 1: Hardhat verification
npx hardhat verify --network sepolia 0x813F34aa27F893C45f419dd9d32561a2639A8E15

# Option 2: Etherscan manual verification
# - Visit: https://sepolia.etherscan.io
# - Search contract address
# - Click "Verify and Publish"
# - Paste contract source
# - Verify parameters
```

### 2. Test Contract Functions

```javascript
// Connect to deployed contract
const contractAddress = "0x813F34aa27F893C45f419dd9d32561a2639A8E15";
const contract = new ethers.Contract(
  contractAddress,
  ABI,
  signer
);

// Test registration
const tx = await contract.registerIdentityProof(
  12345,  // credential
  80      // identity score
);

console.log("Transaction hash:", tx.hash);
await tx.wait();
console.log("✅ Registration successful!");
```

### 3. Set Up Frontend

Update **frontend/script.js** with deployed address:

```javascript
const CONTRACT_ADDRESS = '0x813F34aa27F893C45f419dd9d32561a2639A8E15';
const SEPOLIA_CHAIN_ID = '0xaa36a7';
```

### 4. Monitor Deployment

```bash
# View contract on Sepolia Etherscan
# https://sepolia.etherscan.io/address/0x813F34aa27F893C45f419dd9d32561a2639A8E15

# Check transactions
# Monitor gas usage
# Track event logs
```

## Production Considerations

### Network Selection

**Development**: Local Hardhat node
- Fast testing
- Free operation
- Reset capability

**Staging**: Sepolia testnet
- Real blockchain behavior
- Low cost
- Full testing capability

**Production**: Ethereum mainnet
- Live system
- Real ETH costs
- Irreversible deployment

### Security Measures

1. **Private Key Management**
   - Use hardware wallet when possible
   - Never share private keys
   - Rotate keys periodically
   - Use separate keys for different accounts

2. **Contract Upgrades**
   - Plan upgrade strategy
   - Use proxy patterns if needed
   - Test thoroughly before upgrade

3. **Access Control**
   - Implement multi-sig for critical functions
   - Regular permission audits
   - Revoke unused verifier accounts

4. **Monitoring**
   - Set up transaction alerts
   - Monitor contract events
   - Track unusual activity
   - Maintain audit logs

### Gas Optimization Review

```bash
# Analyze gas usage
REPORT_GAS=true npm run test

# Expected gas costs:
# - Registration: ~150,000 - 200,000
# - Verification: ~200,000 - 250,000
# - Proof submission: ~300,000 - 350,000
```

### Code Audit Recommendations

1. **Internal Review**
   - Line-by-line code review
   - Security pattern validation
   - Best practice compliance

2. **External Audit**
   - Professional security firm
   - Comprehensive vulnerability assessment
   - Gas optimization review

3. **Bug Bounty**
   - Launch after audit
   - Define scope and rules
   - Set reasonable rewards

## Verification and Monitoring

### Transaction Verification

```bash
# Get transaction details
curl "https://sepolia.infura.io/v3/YOUR_INFURA_KEY" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["0xTXHASH"],"id":1}'

# View on Etherscan
# https://sepolia.etherscan.io/tx/0xTXHASH
```

### Contract Monitoring

```javascript
// Listen for events
contract.on('IdentityProofRegistered', (user, timestamp) => {
  console.log(`User ${user} registered at ${timestamp}`);
});

contract.on('VerificationRequested', (requestId, requester) => {
  console.log(`Verification requested by ${requester}, ID: ${requestId}`);
});

contract.on('VerificationCompleted', (requestId, approved, requester) => {
  console.log(`Verification ${requestId} completed: ${approved}`);
});
```

### Analytics Dashboard

Track key metrics:
- Total registrations
- Verification success rate
- Average transaction cost
- Active users
- Failed transactions

## Troubleshooting

### Common Issues

**Issue: "Contract not deployed"**
```
Solution: Check contract address is correct
- Verify on Etherscan
- Check .env file
- Re-run deployment if needed
```

**Issue: "Insufficient funds"**
```
Solution: Get more test ETH
- Visit faucet (see Prerequisites)
- Wait for confirmation
- Verify balance: wallet balance > tx cost
```

**Issue: "Gas estimation failed"**
```
Solution: Check contract state
- Verify prerequisites are met
- Check account authorization
- Ensure proper parameters
```

**Issue: "Transaction reverted"**
```
Solution: Debug revert reason
- Check require() conditions
- Verify modifiers are passed
- Test locally first
```

**Issue: "RPC error"**
```
Solution: Fix network connection
- Check Infura API key
- Verify network selection
- Try different RPC endpoint
```

### Debug Mode

```bash
# Run with debug logging
DEBUG=* npm run deploy:sepolia

# Use hardhat console
npx hardhat console --network sepolia

# Interactive testing
> const contract = await ethers.getContractAt("AnonymousIdentityVerification", "0x...")
> await contract.getContractStats()
```

### Getting Help

1. **Check Logs**: Review console output for clues
2. **Test Locally**: Reproduce issue with `npx hardhat test`
3. **Community**: Ask in Zama Discord or forums
4. **Documentation**: Review Zama FHEVM docs

## Next Steps

After successful deployment:

1. **Frontend Integration**: Connect UI to deployed contract
2. **User Testing**: Gather feedback from early users
3. **Performance Monitoring**: Track metrics over time
4. **Enhancement Planning**: Plan future improvements
5. **Documentation Update**: Keep docs current with changes

## Useful Links

- **Sepolia Testnet Faucet**: https://sepoliafaucet.com
- **Etherscan Sepolia**: https://sepolia.etherscan.io
- **Infura Dashboard**: https://dashboard.infura.io
- **Zama FHEVM Docs**: https://docs.zama.ai/fhevm
- **Hardhat Docs**: https://hardhat.org/docs

---

**Deployment Guide Version**: 1.0
**Last Updated**: December 2025
**Status**: Production Ready
