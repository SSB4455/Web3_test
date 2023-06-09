const main = async () => {
	const contractFactory = await hre.ethers.getContractFactory('MyNFTsBasedGame');
	const gameContract = await contractFactory.deploy(
		["李承远", "Chibimaruko", "Pikachu"],			// Names
		["https://i.imgur.com/J3swmFr.jpeg",			// Images
		"https://i.imgur.com/8Glbz2x.jpeg",
		"https://i.imgur.com/WMB6g9u.png"],
		[500, 30, 100],									// HP values
		[500, 50, 25],									// Attack damage values
		"The Mothor",									// Boss name
		"https://i.imgur.com/VaDC2JL_d.webp",			// Boss image
		10000, // Boss hp
		36 // Boss attack damage
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

	// We add four characters.
	txn = await gameContract.addCharacterAttributes(
		"Seed",									// Name
		"https://i.imgur.com/htdlTWy.jpeg",		// Image
		600,									// Max HP value
		233
	);
	await txn.wait();

	// an NFT w/ the character at index 3 of our array.
	txn = await gameContract.mintCharacterNFT(3);
	await txn.wait();

	// Get the value of the NFT's URI.
	returnedTokenUri = await gameContract.tokenURI(1);
	console.log("Token URI:", returnedTokenUri);

	txn = await gameContract.attackBoss(0);
	await txn.wait();

	txn = await gameContract.attackBoss(1);
	await txn.wait();

	txn = await gameContract.attackBoss(0);
	await txn.wait();

	txn = await gameContract.attackBoss(1);
	await txn.wait();

	txn = await gameContract.reviveBoss();
	await txn.wait();

	txn = await gameContract.reviveCharacter(1);
	await txn.wait();

	txn = await gameContract.attackBoss(1);
	await txn.wait();

	console.log("getUserHasCharacters:", gameContract.getUserHasCharacters());
	console.log("getAllDefaultCharacters:", gameContract.getAllDefaultCharacters());

};

const runMain = async () => {
	try {
		await main();
		process.exit(0);
	} catch (error) {
		console.log(error);
		process.exit(1);
	}
};

runMain();