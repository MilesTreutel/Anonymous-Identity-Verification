#!/usr/bin/env ts-node

/**
 * @title Create FHEVM Category
 * @description TypeScript tool for generating category-based FHEVM example projects
 * @author FHEVM Development Team
 * @version 1.0.0
 */

import * as fs from "fs";
import * as path from "path";

/**
 * Category configuration interface
 */
interface CategoryConfig {
  name: string;
  description: string;
  examples: string[];
  concepts: string[];
  difficulty: string;
}

/**
 * Create category-based FHEVM projects
 * @param categoryName - Name of the category
 * @param examples - List of examples in this category
 * @param outputDir - Output directory
 */
async function createFHEVMCategory(
  categoryName: string,
  examples: string[],
  outputDir: string
): Promise<void> {
  console.log(`Creating FHEVM Category: ${categoryName}`);

  const categoryDir = path.join(outputDir, categoryName.toLowerCase());

  if (!fs.existsSync(categoryDir)) {
    fs.mkdirSync(categoryDir, { recursive: true });
  }

  // Create subdirectories for each example
  for (const example of examples) {
    const exampleDir = path.join(categoryDir, example.toLowerCase());
    const requiredDirs = [
      "contracts",
      "test",
      "scripts",
      "docs",
    ];

    for (const dir of requiredDirs) {
      const dirPath = path.join(exampleDir, dir);
      if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
      }
    }
  }

  // Create category README
  const categoryReadme = `# ${categoryName} Examples

## Overview
This category contains FHEVM examples focused on ${categoryName.toLowerCase()}.

## Examples Included
${examples.map((ex) => `- ${ex}`).join("\n")}

## Key Concepts
- Privacy preservation
- Encrypted computation
- Access control
- Secure validation

## Getting Started
1. Choose an example: \`cd ${examples[0].toLowerCase()}\`
2. Install dependencies: \`npm install\`
3. Compile contracts: \`npm run compile\`
4. Run tests: \`npm run test\`

## Learning Path
Start with simpler examples and progress to more complex ones.

## Documentation
See individual example READMEs for detailed information.
`;

  fs.writeFileSync(
    path.join(categoryDir, "README.md"),
    categoryReadme
  );

  console.log(`✅ Created category: ${categoryName}`);
  console.log(`📁 Location: ${categoryDir}`);
  console.log(`📋 Examples: ${examples.join(", ")}`);
}

/**
 * Define standard FHEVM example categories
 */
const FHEVM_CATEGORIES: Record<string, CategoryConfig> = {
  Basic: {
    name: "Basic",
    description: "Fundamental FHEVM concepts and operations",
    examples: [
      "FHECounter",
      "Arithmetic",
      "Comparison",
    ],
    concepts: [
      "Encrypted integers",
      "Basic operations",
      "FHE functions",
    ],
    difficulty: "Beginner",
  },
  Encryption: {
    name: "Encryption",
    description: "Data encryption and decryption patterns",
    examples: [
      "EncryptSingleValue",
      "EncryptMultipleValues",
      "EncryptionPatterns",
    ],
    concepts: [
      "Input encryption",
      "Type conversion",
      "Access control",
    ],
    difficulty: "Beginner",
  },
  UserDecryption: {
    name: "User Decryption",
    description: "User-specific decryption mechanisms",
    examples: [
      "UserDecryptSingle",
      "UserDecryptMultiple",
      "SelectiveDecryption",
    ],
    concepts: [
      "User permissions",
      "Decryption callbacks",
      "Privacy control",
    ],
    difficulty: "Intermediate",
  },
  PublicDecryption: {
    name: "Public Decryption",
    description: "Public decryption patterns",
    examples: [
      "PublicDecryptSingle",
      "PublicDecryptMultiple",
      "SharedDecryption",
    ],
    concepts: [
      "Public validation",
      "Result publication",
      "Transparency control",
    ],
    difficulty: "Intermediate",
  },
  AccessControl: {
    name: "Access Control",
    description: "Access control and permissions",
    examples: [
      "RoleBasedControl",
      "UserPermissions",
      "DecryptionRights",
    ],
    concepts: [
      "FHE.allow patterns",
      "Permission management",
      "Role enforcement",
    ],
    difficulty: "Intermediate",
  },
  Advanced: {
    name: "Advanced",
    description: "Advanced FHEVM patterns and techniques",
    examples: [
      "BlindAuction",
      "ConfidentialVoting",
      "SecureComputation",
    ],
    concepts: [
      "Complex workflows",
      "Privacy-preserving logic",
      "Advanced patterns",
    ],
    difficulty: "Advanced",
  },
};

/**
 * Main entry point
 */
async function main() {
  const categoryName = process.argv[2];
  const outputDir = process.argv[3] || "./examples";

  if (!categoryName) {
    // Create all categories
    console.log("Creating all FHEVM categories...\n");

    for (const [key, config] of Object.entries(FHEVM_CATEGORIES)) {
      await createFHEVMCategory(config.name, config.examples, outputDir);
      console.log();
    }

    // Create main index
    const indexContent = `# FHEVM Example Categories

## Available Categories
${Object.entries(FHEVM_CATEGORIES)
  .map(
    ([key, config]) =>
      `### ${config.name}
${config.description}

Examples:
${config.examples.map((ex) => `- ${ex}`).join("\n")}`
  )
  .join("\n\n")}

## How to Use
1. Navigate to a category directory
2. Choose an example
3. Follow the README in each example

## Learning Path
Start with "Basic" category, then progress to "Intermediate" and "Advanced" examples.
`;

    fs.writeFileSync(path.join(outputDir, "README.md"), indexContent);
    console.log("✅ All categories created successfully!");
  } else {
    // Create specific category
    const config = FHEVM_CATEGORIES[categoryName];
    if (!config) {
      console.error(`❌ Unknown category: ${categoryName}`);
      console.log(
        `Available categories: ${Object.keys(FHEVM_CATEGORIES).join(", ")}`
      );
      process.exit(1);
    }

    await createFHEVMCategory(categoryName, config.examples, outputDir);
  }
}

main().catch((error) => {
  console.error("❌ Error:", error);
  process.exit(1);
});
