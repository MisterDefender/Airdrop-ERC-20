require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  defaultNetwork: "localhost",
  namedAccounts: {
    deployer: { default: 0 },
  },
  networks: {
    arbSepolia: {
      accounts: [process.env.OWNER_PVT_KEY],
      url: `https://arb-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_ARBITRUM_SEPOLIA_API_KEY}`,
      settings: {
        optimizer: { enabled: true, runs: 9999 },
      },
      gasPrice: "auto",
      saveDeployments: true,
      live: true,
      gasMultiplier: 2,
    },
  },
};
