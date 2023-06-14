// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
	const contractFactory = await hre.ethers.getContractFactory('MyNFTsBasedGame');
	const gameContract = await contractFactory.deploy(
		["李承远", "Chibimaruko", "Pikachu"],			// Names
		["https://img-qn.51miz.com/preview/element/00/01/12/94/E-1129426-CB628E6F.jpg!/quality/90/unsharp/true/compress/true/fwfh/800x800",	// Images
		"https://zh.wikipedia.org/wiki/%E6%AB%BB%E6%A1%83%E5%B0%8F%E4%B8%B8%E5%AD%90#/media/File:%E6%AB%BB%E6%A1%83%E5%B0%8F%E4%B8%B8%E5%AD%90.jpg",
		"https://i.imgur.com/WMB6g9u.png"],
		[500, 30, 100],									// HP values
		[500, 50, 25],									// Attack damage values
		["master", "warrior", "elf"]					// Attack damage values
	);
	await gameContract.deployed();
	console.log("Contract deployed to:", gameContract.address);

	let txn;
	// We only have three characters.
	// an NFT w/ the character at index 0 of our array.
	txn = await gameContract.mintCharacterNFT(0);
	await txn.wait();
	// Get the value of the NFT's URI.
	let returnedTokenUri = await gameContract.tokenURI(0);
	console.log("Token URI:", returnedTokenUri);

	txn = await gameContract.mintCharacterNFT(1);
	await txn.wait();
	returnedTokenUri = await gameContract.tokenURI(1);
	console.log("Token URI:", returnedTokenUri);

	txn = await gameContract.mintCharacterNFT(2);
	await txn.wait();
	returnedTokenUri = await gameContract.tokenURI(2);
	console.log("Token URI:", returnedTokenUri);

	txn = await gameContract.mintCharacterNFT(1);
	await txn.wait();
	returnedTokenUri = await gameContract.tokenURI(3);
	console.log("Token URI:", returnedTokenUri);

	console.log("Done deploying and minting!");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});
