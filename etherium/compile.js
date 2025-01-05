const path = require('path');
const fs = require('fs-extra');
const solc = require('solc');

// Path to the build folder
const buildPath = path.resolve(__dirname, 'build');

// Remove the build folder if it exists
fs.removeSync(buildPath);

// Path to the Solidity contract
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');

// Read the Solidity source code
const source = fs.readFileSync(campaignPath, 'utf8');

// Input JSON for the Solidity compiler
const input = {
  language: 'Solidity',
  sources: {
    'Campaign.sol': {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

// Compile the contract
const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Handle compilation errors
if (output.errors) {
  console.error('Compilation errors:', output.errors);
  process.exit(1);
}

// Create the build folder
fs.ensureDirSync(buildPath);

console.log('Output:', output);
// Write the compiled contracts to the build folder
for (let contractName in output.contracts['Campaign.sol']) {
  const contract = output.contracts['Campaign.sol'][contractName];
  fs.outputJsonSync(
    path.resolve(buildPath, `${contractName}.json`),
    contract
  );
}