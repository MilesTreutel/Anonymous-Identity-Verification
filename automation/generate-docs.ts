#!/usr/bin/env ts-node

/**
 * @title Generate FHEVM Documentation
 * @description Automatic documentation generator from code annotations
 * @author FHEVM Development Team
 * @version 1.0.0
 */

import * as fs from "fs";
import * as path from "path";

/**
 * Documentation metadata interface
 */
interface DocMetadata {
  title: string;
  description: string;
  chapter?: string;
  example?: boolean;
  difficulty?: string;
  concepts?: string[];
}

/**
 * Contract info interface
 */
interface ContractInfo {
  name: string;
  description: string;
  functions: FunctionInfo[];
  events: EventInfo[];
  structs: StructInfo[];
}

/**
 * Function info interface
 */
interface FunctionInfo {
  name: string;
  description: string;
  params: ParamInfo[];
  returns: string;
  visibility: string;
  chapter?: string;
}

/**
 * Parameter info interface
 */
interface ParamInfo {
  name: string;
  type: string;
  description: string;
}

/**
 * Event info interface
 */
interface EventInfo {
  name: string;
  description: string;
  params: ParamInfo[];
}

/**
 * Struct info interface
 */
interface StructInfo {
  name: string;
  description: string;
  fields: ParamInfo[];
}

/**
 * Parse Solidity contract file
 * @param filePath - Path to Solidity file
 * @returns Contract information
 */
function parseSolidityContract(filePath: string): ContractInfo {
  const content = fs.readFileSync(filePath, "utf-8");

  // Extract contract name
  const contractMatch = content.match(/contract\s+(\w+)/);
  const contractName = contractMatch ? contractMatch[1] : "Unknown";

  // Extract description from comments
  const descMatch = content.match(/\/\/\/\s*@title\s+(.+)/);
  const description = descMatch ? descMatch[1] : "No description";

  return {
    name: contractName,
    description: description,
    functions: extractFunctions(content),
    events: extractEvents(content),
    structs: extractStructs(content),
  };
}

/**
 * Extract functions from contract
 * @param content - Contract content
 * @returns Array of function info
 */
function extractFunctions(content: string): FunctionInfo[] {
  const functions: FunctionInfo[] = [];
  const functionRegex =
    /\/\/\/\s*@dev\s+(.+?)\n\s*function\s+(\w+)\s*\((.*?)\)\s*(?:external|public|internal|private).*?(?:returns\s*\((.*?)\))?/gs;

  let match;
  while ((match = functionRegex.exec(content)) !== null) {
    const [, description, name, params, returns] = match;

    functions.push({
      name: name,
      description: description.trim(),
      params: parseParams(params),
      returns: returns || "void",
      visibility: "public",
    });
  }

  return functions;
}

/**
 * Extract events from contract
 * @param content - Contract content
 * @returns Array of event info
 */
function extractEvents(content: string): EventInfo[] {
  const events: EventInfo[] = [];
  const eventRegex =
    /event\s+(\w+)\s*\((.*?)\)/gs;

  let match;
  while ((match = eventRegex.exec(content)) !== null) {
    const [, name, params] = match;

    events.push({
      name: name,
      description: `Event: ${name}`,
      params: parseParams(params),
    });
  }

  return events;
}

/**
 * Extract structs from contract
 * @param content - Contract content
 * @returns Array of struct info
 */
function extractStructs(content: string): StructInfo[] {
  const structs: StructInfo[] = [];
  const structRegex =
    /struct\s+(\w+)\s*\{([\s\S]*?)\}/g;

  let match;
  while ((match = structRegex.exec(content)) !== null) {
    const [, name, fields] = match;

    structs.push({
      name: name,
      description: `Struct: ${name}`,
      fields: parseFields(fields),
    });
  }

  return structs;
}

/**
 * Parse parameters
 * @param paramStr - Parameter string
 * @returns Array of parsed parameters
 */
function parseParams(paramStr: string): ParamInfo[] {
  const params: ParamInfo[] = [];

  if (!paramStr || !paramStr.trim()) {
    return params;
  }

  const parts = paramStr.split(",");
  for (const part of parts) {
    const match = part.trim().match(/(\w+)\s+(\w+)$/);
    if (match) {
      const [, type, name] = match;
      params.push({
        name: name,
        type: type,
        description: "",
      });
    }
  }

  return params;
}

/**
 * Parse struct fields
 * @param fieldsStr - Fields string
 * @returns Array of parsed fields
 */
function parseFields(fieldsStr: string): ParamInfo[] {
  const fields: ParamInfo[] = [];
  const lines = fieldsStr.split(";");

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed) continue;

    const match = trimmed.match(/(\w+)\s+(\w+)$/);
    if (match) {
      const [, type, name] = match;
      fields.push({
        name: name,
        type: type,
        description: "",
      });
    }
  }

  return fields;
}

/**
 * Generate markdown documentation
 * @param contractInfo - Contract information
 * @returns Markdown string
 */
function generateMarkdown(contractInfo: ContractInfo): string {
  let markdown = `# ${contractInfo.name}\n\n`;
  markdown += `${contractInfo.description}\n\n`;

  // Functions section
  if (contractInfo.functions.length > 0) {
    markdown += `## Functions\n\n`;
    for (const func of contractInfo.functions) {
      markdown += `### ${func.name}()\n`;
      markdown += `${func.description}\n\n`;

      if (func.params.length > 0) {
        markdown += `**Parameters:**\n`;
        for (const param of func.params) {
          markdown += `- \`${param.type} ${param.name}\` - ${param.description}\n`;
        }
        markdown += `\n`;
      }

      if (func.returns !== "void") {
        markdown += `**Returns:** \`${func.returns}\`\n\n`;
      }
    }
  }

  // Events section
  if (contractInfo.events.length > 0) {
    markdown += `## Events\n\n`;
    for (const event of contractInfo.events) {
      markdown += `### ${event.name}\n`;
      markdown += `${event.description}\n\n`;

      if (event.params.length > 0) {
        markdown += `**Parameters:**\n`;
        for (const param of event.params) {
          markdown += `- \`${param.type} ${param.name}\`\n`;
        }
        markdown += `\n`;
      }
    }
  }

  // Structs section
  if (contractInfo.structs.length > 0) {
    markdown += `## Structs\n\n`;
    for (const struct of contractInfo.structs) {
      markdown += `### ${struct.name}\n`;
      markdown += `${struct.description}\n\n`;

      markdown += `**Fields:**\n`;
      for (const field of struct.fields) {
        markdown += `- \`${field.type} ${field.name}\`\n`;
      }
      markdown += `\n`;
    }
  }

  return markdown;
}

/**
 * Generate documentation for all contracts
 * @param contractsDir - Contracts directory
 * @param outputDir - Output directory for documentation
 */
function generateAllDocumentation(
  contractsDir: string,
  outputDir: string
): void {
  // Create output directory
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  // Find all Solidity files
  const files = fs.readdirSync(contractsDir);
  const solidityFiles = files.filter((f) => f.endsWith(".sol"));

  console.log(`Found ${solidityFiles.length} contract(s)`);

  // Generate documentation for each contract
  for (const file of solidityFiles) {
    const filePath = path.join(contractsDir, file);
    const contractInfo = parseSolidityContract(filePath);

    // Generate markdown
    const markdown = generateMarkdown(contractInfo);

    // Write to file
    const outputFile = path.join(
      outputDir,
      `${contractInfo.name}.md`
    );
    fs.writeFileSync(outputFile, markdown);

    console.log(`✅ Generated documentation for ${contractInfo.name}`);
  }

  // Generate index
  const indexContent = `# Contract Documentation

## Overview
Auto-generated documentation from Solidity contracts.

## Contracts
${solidityFiles.map((f) => {
  const contractInfo = parseSolidityContract(path.join(contractsDir, f));
  return `- [${contractInfo.name}](./${contractInfo.name}.md)`;
}).join("\n")}

---
Generated with FHEVM Documentation Generator
`;

  fs.writeFileSync(path.join(outputDir, "README.md"), indexContent);
  console.log(`✅ Generated documentation index`);
}

/**
 * Main entry point
 */
async function main() {
  const contractsDir = process.argv[2] || "./contracts";
  const outputDir = process.argv[3] || "./docs";

  console.log("Generating FHEVM Documentation...");
  console.log(`Input: ${contractsDir}`);
  console.log(`Output: ${outputDir}\n`);

  try {
    generateAllDocumentation(contractsDir, outputDir);
    console.log(`\n✅ Documentation generation complete!`);
  } catch (error) {
    console.error(`❌ Error generating documentation:`, error);
    process.exit(1);
  }
}

main();
