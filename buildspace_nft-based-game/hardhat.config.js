require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
// Import and configure dotenv
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.18",
	networks: {
		goerli: {
			url: process.env.STAGING_GOERLI_KEY,
			accounts: [process.env.PRIVATE_KEY],
		},
		sepolia: {
			// This value will be replaced on runtime
			url: process.env.STAGING_SEPOLIA_KEY,
			accounts: [process.env.PRIVATE_KEY],
		},
		mainnet: {
			url: process.env.STAGING_SEPOLIA_KEY,
			accounts: [process.env.PRIVATE_KEY],
		},
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_APIKEY, // Your Etherscan API key
	},
};
