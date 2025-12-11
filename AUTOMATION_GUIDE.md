# FHEVM Automation Guide

## Overview

This guide explains how to use the FHEVM automation scripts to generate and manage example repositories, scaffolding, and documentation.

## Automation Scripts

### 1. create-fhevm-example.ts

Creates a new standalone FHEVM example repository.

**Purpose**: Generate a minimal, complete Hardhat project from a template

**Usage**:
```bash
npx ts-node automation/create-fhevm-example.ts <example-name> [output-dir]
```

**Example**:
```bash
# Create FHECounter example
npx ts-node automation/create-fhevm-example.ts FHECounter ./examples

# Create custom example
npx ts-node automation/create-fhevm-example.ts MyExample ./projects
```

**What it Creates**:
- Directory structure (contracts/, test/, scripts/, docs/)
- package.json with dependencies
- hardhat.config.js with network configuration
- .env.example for configuration
- .gitignore for version control
- README.md with project information
- Sample file structure ready for contracts

**Generated Structure**:
```
FHECounter/
├── contracts/        # Contract files go here
├── test/             # Test files go here
├── scripts/          # Deployment scripts
├── docs/             # Documentation
├── artifacts/        # Compiled output (generated)
├── cache/            # Cache files (generated)
├── hardhat.config.js # Hardhat configuration
├── package.json      # Dependencies
├── .env.example      # Environment template
├── .gitignore        # Git ignore rules
└── README.md         # Project documentation
```

### 2. create-fhevm-category.ts

Creates category-based example projects with multiple examples.

**Purpose**: Generate organized example categories (Basic, Encryption, AccessControl, etc.)

**Usage**:
```bash
# Create specific category
npx ts-node automation/create-fhevm-category.ts Basic ./examples

# Create all categories
npx ts-node automation/create-fhevm-category.ts [output-dir]
```

**Examples**:
```bash
# Create all standard categories
npx ts-node automation/create-fhevm-category.ts ./examples

# Create only AccessControl category
npx ts-node automation/create-fhevm-category.ts AccessControl ./examples

# Create Advanced patterns category
npx ts-node automation/create-fhevm-category.ts Advanced ./examples
```

**Available Categories**:

1. **Basic**
   - FHECounter (encrypted arithmetic)
   - Arithmetic (add, subtract operations)
   - Comparison (equality checks)

2. **Encryption**
   - EncryptSingleValue (single value encryption)
   - EncryptMultipleValues (multiple value encryption)
   - EncryptionPatterns (common patterns)

3. **User Decryption**
   - UserDecryptSingle (single value user decryption)
   - UserDecryptMultiple (multiple value user decryption)
   - SelectiveDecryption (selective disclosure)

4. **Public Decryption**
   - PublicDecryptSingle (public single value)
   - PublicDecryptMultiple (public multiple values)
   - SharedDecryption (shared decryption)

5. **Access Control**
   - RoleBasedControl (role-based permissions)
   - UserPermissions (user-specific permissions)
   - DecryptionRights (decryption access control)

6. **Advanced**
   - BlindAuction (sealed bid auction)
   - ConfidentialVoting (private voting)
   - SecureComputation (advanced patterns)

**Generated Structure**:
```
examples/
├── Basic/
│   ├── FHECounter/
│   ├── Arithmetic/
│   └── Comparison/
├── Encryption/
│   ├── EncryptSingleValue/
│   ├── EncryptMultipleValues/
│   └── EncryptionPatterns/
├── AccessControl/
│   ├── RoleBasedControl/
│   ├── UserPermissions/
│   └── DecryptionRights/
└── README.md (category index)
```

### 3. generate-docs.ts

Auto-generates documentation from contract source code.

**Purpose**: Extract contract metadata and generate GitBook-compatible markdown

**Usage**:
```bash
npx ts-node automation/generate-docs.ts [contracts-dir] [output-dir]
```

**Examples**:
```bash
# Generate docs from contracts/ to docs/
npx ts-node automation/generate-docs.ts ./contracts ./docs

# Generate docs with custom paths
npx ts-node automation/generate-docs.ts ../smart-contracts ./documentation

# Use defaults (./contracts -> ./docs)
npx ts-node automation/generate-docs.ts
```

**What it Extracts**:
- Contract names and descriptions
- Function signatures and documentation
- Event definitions and parameters
- Struct definitions and fields
- Parameter types and descriptions
- Return types

**Output Format**:
```markdown
# ContractName

Contract description and purpose

## Functions

### functionName()
Function description

**Parameters:**
- `type paramName` - parameter description

**Returns:** `returnType`

## Events

### EventName
Event description

**Parameters:**
- `type paramName` - description

## Structs

### StructName
Struct description

**Fields:**
- `type fieldName` - field description
```

**Generated Files**:
- `ContractName.md` - Individual contract documentation
- `README.md` - Documentation index

## Workflow Examples

### Creating a Complete Example Project

```bash
# 1. Create base example
npx ts-node automation/create-fhevm-example.ts MyNewExample ./examples

# 2. Navigate to project
cd examples/MyNewExample

# 3. Install dependencies
npm install

# 4. Create your contract
# Edit contracts/MyContract.sol with your code

# 5. Create tests
# Edit test/MyContract.test.js

# 6. Generate documentation
npx ts-node ../automation/generate-docs.ts ./contracts ./docs

# 7. Test everything
npm run test

# 8. Ready to deploy
npm run deploy:sepolia
```

### Setting Up All Categories

```bash
# 1. Create all categories
npx ts-node automation/create-fhevm-category.ts ./examples

# 2. Add contracts to each example directory
# Copy contracts/ into each example

# 3. Generate documentation for all
for category in examples/*/; do
  for example in "$category"/*/; do
    npx ts-node automation/generate-docs.ts "$example/contracts" "$example/docs"
  done
done

# 4. Create index pages
# Index automatically generated in category and example READMEs
```

## Code Generation Features

### Solidity Contract Annotations

Tag your code with special comments for documentation:

```solidity
/// @title Contract Title
/// @dev Brief description
/// @chapter: category-name

/**
 * @dev Function description
 * @param paramName Parameter description
 * @return Description of return value
 * @notice Important note about the function
 * @example
 * // Usage example
 * await contract.function(param);
 */
function myFunction(uint256 paramName) external returns (bool) {
    // Implementation
}
```

### TypeScript Annotations

Use TSDoc for script documentation:

```typescript
/**
 * @title Function Title
 * @description Detailed description
 * @param param1 Parameter description
 * @returns What the function returns
 * @example
 * // Usage example
 * await myFunction(param1);
 */
async function myFunction(param1: string): Promise<void> {
    // Implementation
}
```

## Integration with npm Scripts

Add these to your `package.json`:

```json
{
  "scripts": {
    "compile": "hardhat compile",
    "test": "hardhat test",
    "deploy": "hardhat run scripts/deploy.js",
    "generate-docs": "ts-node ../automation/generate-docs.ts",
    "create-example": "ts-node ../automation/create-fhevm-example.ts"
  }
}
```

Then use with npm:
```bash
npm run generate-docs
npm run create-example MyExample
```

## Advanced Usage

### Custom Example Configuration

Modify `create-fhevm-example.ts` to customize:

```typescript
const config: ExampleConfig = {
  name: exampleName,
  description: "Custom description",
  category: "Custom",
  concept: "Custom concept",
  features: ["Feature1", "Feature2"],
  difficulty: "intermediate",
};
```

### Documentation Customization

Edit `generate-docs.ts` to adjust:
- Output format
- Markdown styling
- Template structure
- Annotation parsing

### Category Customization

Modify `FHEVM_CATEGORIES` in `create-fhevm-category.ts`:

```typescript
const FHEVM_CATEGORIES: Record<string, CategoryConfig> = {
  MyCategory: {
    name: "My Category",
    description: "Category description",
    examples: ["Example1", "Example2"],
    concepts: ["Concept1", "Concept2"],
    difficulty: "Beginner",
  },
};
```

## Best Practices

1. **Consistent Naming**: Use descriptive names for projects and categories
2. **Clear Documentation**: Add detailed JSDoc/TSDoc comments
3. **Organized Structure**: Keep examples in logical categories
4. **Regular Updates**: Regenerate docs when code changes
5. **Version Control**: Commit generated examples to git
6. **Testing**: Always test examples before committing
7. **Documentation**: Keep README files current

## Troubleshooting

### TypeScript Compilation Errors

```bash
# Ensure tsconfig.json is in project root
# Check Node.js version (v16+)
node --version

# Install TypeScript
npm install -D typescript ts-node
```

### Package Installation Issues

```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Documentation Generation Fails

```bash
# Check contracts directory exists
ls ./contracts

# Verify Solidity files present
ls ./contracts/*.sol

# Check output directory writable
mkdir -p ./docs
```

## Performance Tips

- Use specific categories when creating examples
- Limit category size (< 10 examples per category)
- Run documentation generation in batches
- Cache compiled contracts

## Next Steps

1. Create base examples using automation scripts
2. Customize examples for your use cases
3. Generate comprehensive documentation
4. Test examples thoroughly
5. Deploy to testnet
6. Share with community

---

**Automation Guide Version**: 1.0
**Last Updated**: December 2025
**Status**: Production Ready
