const { Web3 } = require('web3');
require('dotenv').config(); // This loads the environment variables


// Access the environment variables
const infuraProjectId = process.env.INFURA_PROJECT_ID;
const privateKey = process.env.PRIVATE_KEY;
const infuraUrl = process.env.INFURA;

console.log("Infura Project ID:", infuraProjectId);  // Log the values to make sure they are loaded
console.log("Private Key:", privateKey);             // Log the values to make sure they are loaded
console.log("Infura URL:", infuraUrl);               // Log the values to make sure they are loaded

const web3 = new Web3(infuraUrl);  // Connect to Infura

const account = web3.eth.accounts.privateKeyToAccount(privateKey);
web3.eth.accounts.wallet.add(account);

async function main() {
    // Get contract ABI and Bytecode from Hardhat artifacts
    const SimpleStorageArtifact = require('../../artifacts/contracts/SimpleStorage.sol/SimpleStorage.json');
    const abi = SimpleStorageArtifact.abi;
    const bytecode = SimpleStorageArtifact.bytecode;

    // Deploy contract using Web3.js
    const SimpleStorageContract = new web3.eth.Contract(abi);
    const deployedContract = await SimpleStorageContract
        .deploy({ data: bytecode, arguments: [42] })
        .send({ 
            from: account.address, 
            gas: 9000000 });

    simpleStorage = deployedContract; // Assign deployed contract to simpleStorage variable
    console.log('Contract deployed to:', deployedContract.options.address);

    // Interact with the deployed contract
    const storedData = await deployedContract.methods.storedData().call();
    console.log('Stored Data:', storedData);

    // Update the stored data
    const gasEstimateSet = await deployedContract.methods.set(100).estimateGas({ 
        from: account.address });
    await deployedContract.methods.set(100).send({
        from: account.address,
        gas: gasEstimateSet
        });
    const newStoredData = await deployedContract.methods.storedData().call();
    console.log('Updated Stored Data:', newStoredData);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });