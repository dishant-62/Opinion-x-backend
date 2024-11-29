require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition");
// require("@nomiclabs/hardhat-ethers");


module.exports = {
  networks: {
      sepolia: {
          url: `https://eth-sepolia.g.alchemy.com/v2/S2iutyce_QBuQntQPgtUoUY9d1mnF5o6`,
          accounts: [`0x3b571535b28240c57af7ca1eea96f18d3ae856496ca3f407ef4b3bcbe13acc2e`]
      }
  },
  solidity: "0.8.7",
};
