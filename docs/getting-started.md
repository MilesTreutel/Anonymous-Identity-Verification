# Getting Started with Anonymous Identity Verification

This guide will help you get started with the Anonymous Identity Verification FHEVM project.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** >= 20.0.0
- **npm** >= 7.0.0
- **Git** for version control
- **MetaMask** or another Web3 wallet (for testing with frontend)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/fhevm-examples/anonymous-identity-verification.git
cd anonymous-identity-verification
```

### 2. Install Dependencies

```bash
npm install
```

This will install all required dependencies including:
- Hardhat development framework
- FHEVM Solidity library
- TypeScript and testing tools
- Automation utilities

### 3. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` and add your configuration:

```env
# For local development, the defaults work fine
MNEMONIC="test test test test test test test test test test test junk"

# For deploying to Sepolia testnet
INFURA_API_KEY=your_infura_api_key_here
ETHERSCAN_API_KEY=your_etherscan_api_key_here
```

## Quick Start

### Compile Contracts

```bash
npm run compile
```

This compiles all Solidity contracts and generates TypeScript types.

### Run Tests

```bash
npm test
```

Run tests with coverage:

```bash
npm run coverage
```

Run tests with gas reporting:

```bash
REPORT_GAS=true npm test
```

### Deploy Locally

Start a local Hardhat network:

```bash
npm run chain
```

In another terminal, deploy contracts:

```bash
npm run deploy:localhost
```

### Deploy to Sepolia

Ensure you have:
1. Added your mnemonic or private key to `.env`
2. Added Sepolia ETH to your deployment account
3. Added your Infura API key to `.env`

Then deploy:

```bash
npm run deploy:sepolia
```

## Project Structure

```
anonymous-identity-verification/
├── contracts/              # Solidity smart contracts
│   └── AnonymousIdentityVerification.sol
├── examples/              # Example contracts demonstrating FHEVM concepts
│   ├── FHECounter.sol
│   ├── EncryptionExample.sol
│   ├── AccessControlExample.sol
│   ├── UserDecryptionExample.sol
│   ├── InputProofExample.sol
│   └── AntiPatternsExample.sol
├── test/                  # Test files
│   └── AnonymousIdentityVerification.test.js
├── deploy/               # Deployment scripts
│   └── deploy.ts
├── tasks/                # Custom Hardhat tasks
│   ├── accounts.ts
│   └── anonymousIdentity.ts
├── automation/           # Automation tools
│   ├── create-fhevm-example.ts
│   ├── create-fhevm-category.ts
│   └── generate-docs.ts
├── docs/                 # Documentation
└── frontend/            # Web interface
```

## Next Steps

1. **Learn FHEVM Basics**: Read the [Hello FHEVM Tutorial](../HELLO_FHEVM_TUTORIAL.md)
2. **Explore Examples**: Study the example contracts in the `examples/` directory
3. **Understand Architecture**: Review the [Technical Architecture](../TECHNICAL_ARCHITECTURE.md)
4. **Read Best Practices**: Check out [Best Practices](../BEST_PRACTICES.md)
5. **Use Automation Tools**: Learn about the [Automation Guide](../AUTOMATION_GUIDE.md)

## Common Commands

### Development

```bash
npm run compile          # Compile contracts
npm test                 # Run tests
npm run coverage        # Run tests with coverage
npm run lint            # Lint all code
npm run prettier:write  # Format all code
npm run clean           # Clean build artifacts
```

### Deployment

```bash
npm run deploy:localhost    # Deploy to local network
npm run deploy:sepolia      # Deploy to Sepolia testnet
npm run verify:sepolia      # Verify on Etherscan
```

### Automation

```bash
npm run generate-docs       # Generate documentation
npm run create-example      # Create new example project
npm run create-category     # Create category project
```

### Custom Tasks

```bash
npx hardhat accounts                                    # List accounts
npx hardhat verify-identity --contract <address>        # Check contract status
npx hardhat get-identity-status --contract <address> --address <user>  # Check user status
```

## Troubleshooting

### Compilation Errors

If you encounter compilation errors:

```bash
npm run clean
npm install
npm run compile
```

### TypeChain Errors

Regenerate TypeChain types:

```bash
npm run typechain
```

### Network Issues

For Sepolia testnet issues, ensure:
- Your account has sufficient ETH
- Your Infura API key is valid
- Your mnemonic is correct

Get Sepolia ETH from faucets:
- https://sepoliafaucet.com/
- https://www.infura.io/faucet/sepolia

## Support

- **Documentation**: Check the `/docs` directory
- **Issues**: Report on GitHub
- **Community**: Join Zama Discord
- **Forum**: Visit https://www.zama.ai/community

## Learning Resources

- [FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Solidity Documentation](https://docs.soliditylang.org)
- [Example Projects](https://github.com/zama-ai/dapps)

---

Ready to build privacy-preserving applications? Continue to the [Hello FHEVM Tutorial](../HELLO_FHEVM_TUTORIAL.md)!
