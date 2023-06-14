require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: "0.8.18",
	networks: {
		sepolia: {
			// This value will be replaced on runtime
			url: 'https://eth-sepolia.g.alchemy.com/v2/AaF6AH_k7jw4DiFjXHRr23gUk9EDQOB6',
			accounts: ['3f'],
		},
	},
};
