require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.19",
  defaultNetwork: "sepolia",
  networks: {
    hardhat: {},
    sepolia: {
      url: process.env.API_URL,
      accounts: [`0x${process.env.PRIVATE_KEY}`]
    }
  },
}