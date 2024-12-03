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

const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const rpcEndpoint = "http://127.0.0.1:8545";

const app = express();

const web3 = new Web3(new Web3.providers.HttpProvider(rpcEndpoint));

const contract = new web3.eth.Contract(contractABI, contractAddress);

const fromAddress = "0xB9E0bC650F8E0E7701f299065749C1Fb50C22576";
app.use(express.json());

// app.get("/team", async (req,res) => {
//     const team = await contract.methods.add(3,4).call();
//     // console.log.json({team});
//     res.json({team});
//     // const gas = 1000000;
// //     const linkBalance = await apiConsumer.checkLinkBalance();
// //     console.log("LINK Balance:", linkBalance.toString());
// //     if (linkBalance < fee) {
// //     console.error("Insufficient LINK balance. Please fund the contract.");
// // }
//     try {
//         const result = await myContract.methods.add(3,4).call();
//         // const gas = 1000000;);
//         console.log(result);
//     } catch (error) {
//         console.error('Error:', error);
//     }
//     console.log({team});
// });

app.get("/team", async (req, res) => {
    try {
        const result = await contract.methods.add(3, 4).call();
        console.log("Addition Result:", result);
        res.json({ result });
    } catch (error) {
        console.error("Error:", error.message);
        res.status(500).json({ error: error.message });
    }
});



app.listen(3000, ()=>{
    //sds
    console.log("Server running");
});

