# FHEVM Example Base Template

This is the base template for creating standalone FHEVM example repositories.

## Quick Start

### 1. Copy This Template

```bash
cp -r base-template/ my-fhevm-example
cd my-fhevm-example
```

### 2. Customize

- Replace `contracts/` with your example contract
- Update `test/` with your test cases
- Update `deploy/deploy.ts` with your contract name

### 3. Install and Test

```bash
npm install
npm run compile
npm run test
```

## Project Structure

```
base-template/
├── contracts/          # Solidity contracts
├── test/              # Test files
├── deploy/            # Deployment scripts
├── tasks/             # Custom Hardhat tasks
├── hardhat.config.ts  # Hardhat configuration
├── package.json       # Dependencies
└── tsconfig.json      # TypeScript config
```

## Available Scripts

```bash
npm run compile          # Compile contracts
npm run test            # Run tests
npm run coverage        # Run tests with coverage
npm run lint            # Lint code
npm run prettier:write  # Format code
npm run deploy:localhost # Deploy to local network
npm run deploy:sepolia   # Deploy to Sepolia testnet
```

## Documentation

- [Getting Started Guide](../docs/getting-started.md)
- [FHEVM Tutorial](../HELLO_FHEVM_TUTORIAL.md)
- [Best Practices](../BEST_PRACTICES.md)

## Requirements

- Node.js >= 20
- npm >= 7.0.0

## License

BSD-3-Clause-Clear
