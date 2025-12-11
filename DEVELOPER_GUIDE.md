# Developer Guide: Building on Anonymous Identity Verification

## Table of Contents
1. [Project Overview](#project-overview)
2. [Setting Up Development Environment](#setting-up-development-environment)
3. [Code Structure and Organization](#code-structure-and-organization)
4. [Smart Contract Development](#smart-contract-development)
5. [Frontend Development](#frontend-development)
6. [Testing and Validation](#testing-and-validation)
7. [Adding New Features](#adding-new-features)
8. [Maintaining and Updating](#maintaining-and-updating)
9. [Common Development Tasks](#common-development-tasks)
10. [Performance Profiling](#performance-profiling)

## Project Overview

### Mission
The Anonymous Identity Verification System is a privacy-preserving smart contract that demonstrates FHEVM capabilities for practical identity management applications.

### Key Technologies
- **Blockchain**: Ethereum (Sepolia testnet)
- **Smart Contracts**: Solidity ^0.8.24
- **Privacy**: Zama FHEVM (Fully Homomorphic Encryption)
- **Framework**: Hardhat
- **Testing**: Chai + Ethers.js
- **Frontend**: Vanilla JavaScript + Ethers.js

### Project Goals
✅ Demonstrate FHE practical applications
✅ Provide secure identity verification
✅ Maintain complete privacy
✅ Educational resource for developers
✅ Production-ready code quality

## Setting Up Development Environment

### Prerequisites
```bash
# System requirements
Node.js: v16.0.0 or higher
npm: v8.0.0 or higher
Git: Latest version
RAM: Minimum 2GB
Disk: Minimum 500MB

# Check versions
node --version
npm --version
git --version
```

### Initial Setup

```bash
# 1. Clone repository
git clone https://github.com/YourUsername/AnonymousIdentityVerification.git
cd AnonymousIdentityVerification

# 2. Install dependencies
npm install

# 3. Create environment file
cp .env.example .env
# Edit .env with your configuration

# 4. Verify setup
npm run compile
npm run test
```

### Development Tools Setup

```bash
# Install Hardhat globally (optional)
npm install -g hardhat

# Install VSCode extensions
# - Solidity (Juan Blanco)
# - Prettier
# - ESLint

# Configure VSCode settings.json
{
  "editor.formatOnSave": true,
  "[solidity]": {
    "editor.defaultFormatter": "JuanBlanco.solidity",
    "editor.formatOnSave": true
  }
}
```

## Code Structure and Organization

### Directory Tree

```
AnonymousIdentityVerification/
├── contracts/
│   ├── AnonymousIdentityVerification.sol    # Main contract
│   └── interfaces/ (future)
│
├── test/
│   ├── AnonymousIdentityVerification.test.js # Test suite
│   └── fixtures/ (future)
│
├── scripts/
│   ├── deploy.js                            # Deployment script
│   └── helpers/ (future)
│
├── frontend/
│   ├── index.html                           # Main UI
│   ├── script.js                            # Web3 integration
│   └── style.css                            # Styling
│
├── artifacts/                               # Compiled contracts (generated)
├── cache/                                   # Cache (generated)
├── node_modules/                            # Dependencies
│
├── .env                                     # Environment config
├── .env.example                             # Config template
├── .gitignore                               # Git ignore rules
├── hardhat.config.js                        # Hardhat configuration
├── package.json                             # Project metadata
├── package-lock.json                        # Dependency lock
│
├── README.md                                # User documentation
├── HELLO_FHEVM_TUTORIAL.md                 # Learning resource
├── DEPLOYMENT_GUIDE.md                      # Deployment instructions
├── TECHNICAL_ARCHITECTURE.md                # Architecture documentation
├── BEST_PRACTICES.md                        # Development standards
├── DEVELOPER_GUIDE.md                       # This file
└── SUBMISSION_README.md                     # Competition submission
```

### File Organization Principles

**By Layer:**
- `contracts/` - Smart contract logic
- `test/` - Test code
- `scripts/` - Automation scripts
- `frontend/` - User interface

**By Concern:**
- Business logic separate from infrastructure
- Tests parallel to source structure
- Documentation with code

**By Feature (Future Expansion):**
```
contracts/
├── core/
│   └── AnonymousIdentityVerification.sol
├── interfaces/
│   └── IIdentityVerification.sol
├── libraries/
│   └── ProofValidation.sol
└── upgrades/
    └── ProxyPatterns.sol
```

## Smart Contract Development

### Adding New Functions

#### Step 1: Design the Function

```solidity
/**
 * @dev [Description of what function does]
 * @param param1 [Description of parameter]
 * @return [Description of return value]
 * @notice [Special considerations]
 */
function newFunction(uint256 param1) external returns (bool) {
    // Implementation
}
```

#### Step 2: Implement with Safety

```solidity
// ✅ TEMPLATE: Safe function implementation
function newFunction(uint256 param1) external onlyAuthorized {
    // 1. Validate inputs
    require(param1 > 0, "Invalid parameter");

    // 2. Check state
    require(isValidState(), "Invalid state");

    // 3. Update state
    state = newValue;

    // 4. Emit event
    emit FunctionExecuted(msg.sender, param1);
}
```

#### Step 3: Add Tests

```javascript
describe("newFunction", function () {
    it("should execute successfully with valid parameters", async function () {
        const tx = await contract.newFunction(123);
        await tx.wait();
        // Add assertions
    });

    it("should reject invalid parameters", async function () {
        await expect(
            contract.newFunction(0)
        ).to.be.revertedWith("Invalid parameter");
    });

    it("should emit correct event", async function () {
        const tx = await contract.newFunction(123);
        await expect(tx)
            .to.emit(contract, "FunctionExecuted")
            .withArgs(owner.address, 123);
    });
});
```

### Modifying Existing Functions

```solidity
// ❌ DON'T: Break existing behavior
function registerIdentityProof(uint32 credential, uint8 score, string memory data) {
    // Added new parameter breaks existing calls
}

// ✅ DO: Create new function or use optional parameters
function registerIdentityProofWithMetadata(
    uint32 credential,
    uint8 score,
    string memory data
) external {
    // New function, existing function unchanged
}
```

### Adding Access Control

```solidity
// Define new role
mapping(address => bool) public approvers;

// Create modifier
modifier onlyApprover() {
    require(approvers[msg.sender], "Not an approver");
    _;
}

// Add management functions
function addApprover(address approver) external onlyOwner {
    approvers[approver] = true;
    emit ApproverAdded(approver);
}

function removeApprover(address approver) external onlyOwner {
    approvers[approver] = false;
    emit ApproverRemoved(approver);
}

// Use in function
function approveVerification(uint32 requestId) external onlyApprover {
    // Implementation
}
```

### Using Encrypted Operations

```solidity
// ✅ Pattern: Working with encrypted values
function processEncryptedData(euint32 encryptedValue) external {
    // 1. Grant access to contract
    FHE.allowThis(encryptedValue);

    // 2. Grant access to user
    FHE.allow(encryptedValue, msg.sender);

    // 3. Store encrypted value
    state.encryptedData = encryptedValue;

    // 4. Request decryption if needed
    bytes32[] memory cts = new bytes32[](1);
    cts[0] = FHE.toBytes32(encryptedValue);
    FHE.requestDecryption(cts, this.processDecrypted.selector);
}

// 5. Handle decrypted result
function processDecrypted(uint256 requestId, uint32 decryptedValue) external {
    // Process the decrypted value
    state.result = decryptedValue;
}
```

## Frontend Development

### Understanding the Current Frontend

```javascript
// Current structure
const CONTRACT_ADDRESS = '0x813F34aa27F893C45f419dd9d32561a2639A8E15';
const SEPOLIA_CHAIN_ID = '0xaa36a7';

// Web3 connection flow:
// 1. connectWallet() - User connects MetaMask
// 2. registerIdentity() - Call contract function
// 3. requestVerification() - Request verification
// 4. submitProof() - Submit cryptographic proof
```

### Adding UI Components

#### HTML Structure

```html
<!-- ✅ Pattern: Self-contained component -->
<div id="newFeatureSection" class="section">
    <h2>New Feature</h2>
    <input type="text" id="newFeatureInput" placeholder="Enter value">
    <button id="newFeatureBtn">Execute Feature</button>
    <div id="newFeatureResult" class="result hidden"></div>
</div>
```

#### JavaScript Handler

```javascript
// Event listener
document.getElementById('newFeatureBtn').addEventListener('click', async () => {
    try {
        const input = document.getElementById('newFeatureInput').value;

        // Validate
        if (!input) {
            showError('Please enter a value');
            return;
        }

        // Show loading
        showLoading('Processing...');

        // Call contract
        const tx = await contract.newFeature(input);

        // Wait for confirmation
        await tx.wait();

        // Show result
        hideLoading();
        showSuccess('Feature executed successfully!');
        updateUI();

    } catch (error) {
        hideLoading();
        showError('Error: ' + error.message);
    }
});

// Helper functions
function showLoading(message) {
    document.getElementById('status').textContent = message;
    document.getElementById('status').classList.remove('hidden');
}

function hideLoading() {
    document.getElementById('status').classList.add('hidden');
}

function showSuccess(message) {
    console.log('✅', message);
    // Update UI feedback
}

function showError(message) {
    console.error('❌', message);
    alert(message);
}
```

### Web3 Integration Patterns

```javascript
// Pattern 1: Check wallet connection
async function ensureConnected() {
    if (!contract) {
        await connectWallet();
    }
}

// Pattern 2: Handle transaction
async function executeTransaction(txPromise, description) {
    try {
        console.log(`Starting: ${description}`);
        const tx = await txPromise;
        console.log(`Transaction sent: ${tx.hash}`);

        const receipt = await tx.wait();
        console.log(`Confirmed in block: ${receipt.blockNumber}`);

        return receipt;
    } catch (error) {
        console.error(`Failed: ${description}`, error);
        throw error;
    }
}

// Pattern 3: Listen to events
contract.on('EventName', (param1, param2) => {
    console.log(`Event: ${param1}, ${param2}`);
    updateUI();
});
```

## Testing and Validation

### Writing Test Cases

```javascript
// ✅ Test template
describe("Feature Name", function () {
    let contract, owner, user;

    // Setup
    beforeEach(async function () {
        [owner, user] = await ethers.getSigners();
        const factory = await ethers.getContractFactory("ContractName");
        contract = await factory.deploy();
    });

    describe("Happy Path", function () {
        it("should do X with valid input Y", async function () {
            // Arrange
            const input = 123;

            // Act
            const result = await contract.functionName(input);

            // Assert
            expect(result).to.equal(expectedOutput);
        });
    });

    describe("Error Cases", function () {
        it("should reject invalid input", async function () {
            await expect(
                contract.functionName(invalidInput)
            ).to.be.revertedWith("Error message");
        });
    });

    describe("Events", function () {
        it("should emit correct event", async function () {
            await expect(contract.functionName(input))
                .to.emit(contract, "EventName")
                .withArgs(expectedArg1, expectedArg2);
        });
    });
});
```

### Running Test Suites

```bash
# Run all tests
npm run test

# Run specific test file
npx hardhat test test/AnonymousIdentityVerification.test.js

# Run with output
npx hardhat test --verbose

# Run with gas reporting
REPORT_GAS=true npm run test

# Run with coverage
npx hardhat coverage

# Run tests in watch mode
npx hardhat test --watch
```

## Adding New Features

### Feature: Multi-Level Identity Verification

**Step 1: Design**
```
Add support for multiple verification levels (basic, standard, premium)
Each level has different requirements and benefits
```

**Step 2: Update Smart Contract**

```solidity
// 1. Add new constants
enum VerificationLevel { BASIC, STANDARD, PREMIUM }
uint8 constant BASIC_SCORE = 50;
uint8 constant STANDARD_SCORE = 75;
uint8 constant PREMIUM_SCORE = 90;

// 2. Update struct
struct IdentityProof {
    // ... existing fields
    VerificationLevel level;
    bool isPremiumVerified;
}

// 3. Add new function
function requestLevelVerification(VerificationLevel level) external {
    // Require appropriate score
    if (level == VerificationLevel.PREMIUM) {
        require(identityProofs[msg.sender].identityScore >= PREMIUM_SCORE);
    }
    // ... rest of implementation
}

// 4. Add events
event LevelVerificationRequested(
    uint32 indexed requestId,
    address indexed requester,
    VerificationLevel level
);
```

**Step 3: Update Tests**

```javascript
describe("Multi-Level Verification", function () {
    it("should request basic verification", async function () {
        // Test implementation
    });

    it("should request premium verification only with high score", async function () {
        // Test implementation
    });
});
```

**Step 4: Update Frontend**

```javascript
// Add dropdown for verification level
const levelSelect = document.getElementById('verificationLevel');

// Handle selection
levelSelect.addEventListener('change', async (e) => {
    const level = e.target.value;
    await requestLevelVerification(level);
});
```

## Maintaining and Updating

### Code Maintenance Workflow

```bash
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Make changes with tests
# Edit contracts, tests, documentation

# 3. Run full test suite
npm run test
REPORT_GAS=true npm run test

# 4. Check coverage
npx hardhat coverage

# 5. Update documentation
# Update README.md, add comments

# 6. Commit with clear message
git add .
git commit -m "Add new feature: description"

# 7. Push and create PR
git push origin feature/new-feature
# Create pull request on GitHub

# 8. After approval, merge
git checkout main
git pull origin main
git merge feature/new-feature
git push origin main
```

### Version Management

```
Version scheme: MAJOR.MINOR.PATCH

MAJOR: Breaking changes, new contract deploys
MINOR: New features, backwards compatible
PATCH: Bug fixes

Example: 1.0.0 -> 1.1.0 (new feature) -> 1.1.1 (bug fix)
```

### Dependency Updates

```bash
# Check for outdated packages
npm outdated

# Update specific package
npm update @fhevm/solidity

# Update all packages
npm update

# Security audit
npm audit
npm audit fix
```

## Common Development Tasks

### Task 1: Add a New Event

```solidity
// 1. Define event
event NewEventName(address indexed user, uint256 value, string reason);

// 2. Emit event
emit NewEventName(msg.sender, amount, "reason");

// 3. Test event
it("should emit NewEventName", async function () {
    await expect(contract.functionName())
        .to.emit(contract, "NewEventName")
        .withArgs(userAddress, expectedAmount, "reason");
});

// 4. Listen in frontend
contract.on('NewEventName', (user, value, reason) => {
    console.log(`Event: ${user}, ${value}, ${reason}`);
});
```

### Task 2: Add Access Control

```solidity
// 1. Define role
mapping(address => bool) public admins;

// 2. Create modifier
modifier onlyAdmin() {
    require(admins[msg.sender], "Not admin");
    _;
}

// 3. Add management
function makeAdmin(address user) external onlyOwner {
    admins[user] = true;
}

// 4. Use modifier
function adminFunction() external onlyAdmin {
    // Only admins can call
}

// 5. Test access control
it("should allow only admins", async function () {
    await expect(
        contract.connect(nonAdmin).adminFunction()
    ).to.be.revertedWith("Not admin");
});
```

### Task 3: Deploy New Version

```bash
# 1. Increment version in package.json
"version": "1.1.0"

# 2. Test thoroughly
npm run test
npm run test -- --coverage

# 3. Deploy to testnet
npm run deploy:sepolia

# 4. Verify on Etherscan
npx hardhat verify --network sepolia CONTRACT_ADDRESS

# 5. Update documentation
# - Update contract address in frontend
# - Update DEPLOYMENT_GUIDE.md
# - Add migration notes if needed

# 6. Release
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin main --tags
```

## Performance Profiling

### Gas Analysis

```bash
# Run tests with gas reporting
REPORT_GAS=true npm run test

# Output sample:
# Function              calls  avg     [min]   [max]
# registerIdentityProof 10     165234  152000  178000
# requestVerification   8      215000  200000  250000
```

### Optimization Techniques

```solidity
// 1. Reduce storage writes
// ❌ Multiple writes
state.field1 = val1;
state.field2 = val2;

// ✅ Single write
state = State({field1: val1, field2: val2});

// 2. Use events instead of storage
// ❌ Store everything
mapping(uint256 => string) history;

// ✅ Use events
event HistoryEntry(uint256 indexed id, string data);

// 3. Optimize loops
// ❌ Unbounded loop
for (uint i = 0; i < users.length; i++) { }

// ✅ Batch with limit
function cleanupBatch(address[] calldata users, uint256 maxCount) external {
    uint256 count = Math.min(users.length, maxCount);
    for (uint i = 0; i < count; i++) { }
}
```

## Troubleshooting Common Issues

### Issue: Tests Fail After Update

```bash
# Solution:
# 1. Clean cache
npm run hardhat clean

# 2. Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# 3. Recompile
npm run compile

# 4. Run tests
npm run test
```

### Issue: Deployment Fails

```bash
# Solution:
# 1. Check RPC connection
npx hardhat test --network sepolia

# 2. Verify gas funds
# - Check wallet balance
# - Ensure Infura API key is correct

# 3. Check contract code
npm run compile -- --verbose

# 4. Deploy locally first
npx hardhat run scripts/deploy.js
```

### Issue: Frontend Can't Connect

```javascript
// Solution:
// 1. Verify contract address
console.log('Contract address:', CONTRACT_ADDRESS);

// 2. Check network
console.log('Current chain:', await provider.getNetwork());

// 3. Verify ABI
console.log('ABI length:', CONTRACT_ABI.length);

// 4. Check wallet connection
const signer = await provider.getSigner();
console.log('Signer:', signer.getAddress());
```

## Resources

### Documentation
- [Zama FHEVM Docs](https://docs.zama.ai/fhevm)
- [Hardhat Docs](https://hardhat.org/docs)
- [Solidity Docs](https://docs.soliditylang.org)
- [Ethers.js Docs](https://docs.ethers.io)

### Community
- [Zama Discord](https://discord.com/invite/zama)
- [Zama Forum](https://www.zama.ai/community)
- [GitHub Issues](https://github.com/YourUsername/AnonymousIdentityVerification/issues)

### Tools
- [Remix IDE](https://remix.ethereum.org/)
- [Etherscan](https://sepolia.etherscan.io/)
- [MetaMask](https://metamask.io/)

---

**Developer Guide Version**: 1.0
**Last Updated**: December 2025
**Status**: Production Ready
**Maintainers**: Community
