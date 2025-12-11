#!/usr/bin/env ts-node

/**
 * @title Create FHEVM Example
 * @description TypeScript CLI tool for generating standalone FHEVM example repositories
 * @author FHEVM Development Team
 * @version 1.0.0
 */

import * as fs from "fs";
import * as path from "path";
import * as child_process from "child_process";

/**
 * Configuration for example project generation
 */
interface ExampleConfig {
  name: string;
  description: string;
  category: string;
  concept: string;
  features: string[];
  difficulty: "beginner" | "intermediate" | "advanced";
}

/**
 * Create FHEVM example project from base template
 * @param exampleName - Name of the example to create
 * @param config - Example configuration
 * @param outputDir - Output directory for the project
 */
async function createFHEVMExample(
  exampleName: string,
  config: ExampleConfig,
  outputDir: string
): Promise<void> {
  console.log(`Creating FHEVM Example: ${exampleName}`);
  console.log(`Category: ${config.category}`);
  console.log(`Difficulty: ${config.difficulty}`);

  // 1. Create base directory
  const projectDir = path.join(outputDir, exampleName);
  if (!fs.existsSync(projectDir)) {
    fs.mkdirSync(projectDir, { recursive: true });
    console.log(`✅ Created project directory: ${projectDir}`);
  }

  // 2. Create directory structure
  const dirs = [
    "contracts",
    "test",
    "scripts",
    "docs",
    "artifacts",
    "cache",
  ];

  for (const dir of dirs) {
    const dirPath = path.join(projectDir, dir);
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
    }
  }
  console.log(`✅ Created project structure`);

  // 3. Create package.json
  const packageJson = {
    name: `fhevm-${exampleName.toLowerCase()}`,
    version: "1.0.0",
    description: config.description,
    main: "index.js",
    scripts: {
      compile: "hardhat compile",
      test: "hardhat test",
      deploy: "hardhat run scripts/deploy.js",
      "deploy:sepolia": "hardhat run scripts/deploy.js --network sepolia",
    },
    keywords: [
      "blockchain",
      "ethereum",
      "fhe",
      "zama",
      ...config.features,
    ],
    author: "",
    license: "MIT",
    devDependencies: {
      "@nomicfoundation/hardhat-toolbox": "^4.0.0",
      hardhat: "^2.19.0",
    },
    dependencies: {
      "@fhevm/solidity": "^0.4.0",
    },
  };

  fs.writeFileSync(
    path.join(projectDir, "package.json"),
    JSON.stringify(packageJson, null, 2)
  );
  console.log(`✅ Created package.json`);

  // 4. Create hardhat.config.js
  const hardhatConfig = `require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL || "",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
};
`;

  fs.writeFileSync(
    path.join(projectDir, "hardhat.config.js"),
    hardhatConfig
  );
  console.log(`✅ Created hardhat.config.js`);

  // 5. Create .env.example
  const envExample = `# Wallet Configuration
PRIVATE_KEY=your_private_key_here

# RPC Provider Configuration
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY

# Optional: Etherscan verification
ETHERSCAN_API_KEY=your_etherscan_key
`;

  fs.writeFileSync(path.join(projectDir, ".env.example"), envExample);
  console.log(`✅ Created .env.example`);

  // 6. Create .gitignore
  const gitignore = `node_modules/
.env
.env.local
.env.*.local
dist/
artifacts/
cache/
coverage/
.hardhat_node/
*.log
.DS_Store
`;

  fs.writeFileSync(path.join(projectDir, ".gitignore"), gitignore);
  console.log(`✅ Created .gitignore`);

  // 7. Create README.md
  const readme = `# ${exampleName} - FHEVM Example

## Description
${config.description}

## Category
${config.category}

## Difficulty Level
${config.difficulty}

## Features
${config.features.map((f) => `- ${f}`).join("\n")}

## Getting Started

### Prerequisites
- Node.js v16+
- npm v8+
- MetaMask or Web3 wallet

### Installation

\`\`\`bash
# Install dependencies
npm install

# Compile contracts
npm run compile

# Run tests
npm run test

# Deploy to Sepolia
npm run deploy:sepolia
\`\`\`

## Architecture

This example demonstrates:
- FHEVM concept: ${config.concept}
- Privacy preservation through homomorphic encryption
- Secure smart contract interactions
- Best practices for encrypted computation

## Key Concepts

### FHEVM Operations
- Data encryption and decryption
- Homomorphic computations
- Access control patterns
- Proof verification

### Privacy Patterns
- Encrypted state management
- User-specific decryption permissions
- Audit trail with events
- Time-based security mechanisms

## Smart Contract Details

\`\`\`solidity
// Key components in this example:
- Encrypted data structures
- FHE operations demonstration
- Secure validation mechanisms
- Event logging for audit
\`\`\`

## Testing

Run comprehensive test suite:
\`\`\`bash
npm run test
\`\`\`

## Deployment

Deploy to Sepolia testnet:
\`\`\`bash
npm run deploy:sepolia
\`\`\`

## Learn More

- [Zama FHEVM Documentation](https://docs.zama.ai/fhevm)
- [Hardhat Documentation](https://hardhat.org/docs)
- [Solidity Documentation](https://docs.soliditylang.org)

## License
MIT
`;

  fs.writeFileSync(path.join(projectDir, "README.md"), readme);
  console.log(`✅ Created README.md`);

  console.log(`\n✅ FHEVM Example Created Successfully: ${exampleName}`);
  console.log(`📁 Location: ${projectDir}`);
  console.log(`\nNext steps:`);
  console.log(`1. cd ${exampleName}`);
  console.log(`2. npm install`);
  console.log(`3. npm run compile`);
  console.log(`4. npm run test`);
}

/**
 * Main entry point
 */
async function main() {
  const exampleName = process.argv[2] || "fhevm-counter";
  const outputDir = process.argv[3] || "./examples";

  const config: ExampleConfig = {
    name: exampleName,
    description: `FHEVM ${exampleName} example demonstrating privacy-preserving smart contracts`,
    category: "Basic",
    concept: "Encrypted computation",
    features: ["FHE operations", "Privacy preservation", "Secure validation"],
    difficulty: "beginner",
  };

  try {
    await createFHEVMExample(exampleName, config, outputDir);
  } catch (error) {
    console.error(`❌ Error creating FHEVM example:`, error);
    process.exit(1);
  }
}

main();
