// const { ethers } = require("ethers");

// const { JsonRpcProvider } = require("ethers"); // or use ES Modules
// const provider = new JsonRpcProvider("https://eth-sepolia.g.alchemy.com/v2/S2iutyce_QBuQntQPgtUoUY9d1mnF5o6");



// const contractAddress = "0x5fbdb2315678afecb367f032d93f642f64180aa3";

// const contractABI = require("./artifacts/contracts/Lock.sol/APIConsumer.json").abi;

// const contract = new ethers.Contract(contractAddress, contractABI, provider);

// const fetchTeamName = async () => {
//     try {
//         // Call the smart contract function to retrieve team name
//         const teamName = await contract.teamNameFromAPI();
//         console.log("Team Name from API:", teamName);
//     } catch (error) {
//         console.error("Error fetching team name:", error);
//     }
// };

// fetchTeamName();

const express  = require("express");
const Web3 = require("web3");
const Mycontract = require("./APIConsumer.json");
const contractABI = Mycontract.abi;

const contractAddress = "0x5fbdb2315678afecb367f032d93f642f64180aa3";
const rpcEndpoint = "https://127.0.0.1:8545";

const app = express();

const web3 = new Web3(new Web3.providers.HttpProvider(rpcEndpoint));

const contract = new web3.eth.Contract(contractABI, contractAddress);

app.use(express.json());

app.get("/team", async (req,res) => {
    const team = await contract.methods.requestVolumeData().call();
    res.json({team});
});

app.listen(3000, ()=>{
    console.log("Server running");
});

