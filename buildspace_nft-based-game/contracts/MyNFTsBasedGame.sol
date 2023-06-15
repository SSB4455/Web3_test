// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyNFTsBasedGame is ERC721 {
	// We'll hold our character's attributes in a struct. Feel free to add
	// whatever you'd like as an attribute! (ex. defense, crit chance, etc).
	struct CharacterAttributes {
		uint characterIndex;
		string name;
		string imageURI;
		uint hp;
		uint maxHp;
		uint attackDamage;
		string job;
	}

	struct BigBoss {
		string name;
		string imageURI;
		uint hp;
		uint maxHp;
		uint attackDamage;
	}

	BigBoss public bigBoss;


	// The tokenId is the NFTs unique identifier, it's just a number that goes
	// 0, 1, 2, 3, etc.
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIds;

	// A lil array to help us hold the default data for our characters.
	// This will be helpful when we mint new characters and need to know
	// things like their HP, AD, etc.
	CharacterAttributes[] defaultCharacters;

	// We create a mapping from the nft's tokenId => that NFTs attributes.
	mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

	// A mapping from an address => the NFTs tokenId. Gives me an ez way
	// to store the owner of the NFT and reference it later.
	mapping(address => uint256) public nftHolders;

	constructor(
		string[] memory characterNames,
		string[] memory characterImageURIs,
		uint[] memory characterHp,
		uint[] memory characterAttackDmg,
		string[] memory jobs,
		// Below, you can also see I added some special identifier symbols for our NFT.
		// This is the name and symbol for our token, ex Ethereum and ETH. I just call mine
		// Heroes and HERO. Remember, an NFT is just a token!
		string memory bossName, // These new variables would be passed in via run.js or deploy.js.
		string memory bossImageURI,
		uint bossHp,
		uint bossAttackDamage
	)
	ERC721("Heroes", "HERO")
	{
		for(uint i = 0; i < characterNames.length; i += 1) {
			defaultCharacters.push(CharacterAttributes({
				characterIndex: i,
				name: characterNames[i],
				imageURI: characterImageURIs[i],
				hp: characterHp[i],
				maxHp: characterHp[i],
				attackDamage: characterAttackDmg[i],
				job: jobs[i]
			}));

			CharacterAttributes memory c = defaultCharacters[i];
			
			// Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
			console.log("Done initializing %s w/ job %s, img %s", c.name, c.job, c.imageURI);
		}

		// Initialize the boss. Save it to our global "bigBoss" state variable.
		bigBoss = BigBoss({
			name: bossName,
			imageURI: bossImageURI,
			hp: bossHp,
			maxHp: bossHp,
			attackDamage: bossAttackDamage
		});

		// I increment _tokenIds here so that my first NFT has an ID of 1.
		// More on this in the lesson!
		//_tokenIds.increment();
	}

	function attackBoss() public {
		// Get the state of the player's NFT.
		uint256 playersTokenId = nftHolders[msg.sender];
		CharacterAttributes storage character = nftHolderAttributes[playersTokenId];

		console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", character.name, character.hp, character.attackDamage);
		console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
		
		// Make sure the character has more than 0 HP.
		require (
			character.hp > 0,
			"Error: character must have HP to attack boss."
		);

		// Make sure the boss has more than 0 HP.
		require (
			bigBoss.hp > 0,
			"Error: boss must have HP to attack character."
		);
		
		console.log("%s swings at %s...", character.name, bigBoss.name); 
		// Allow character to attack boss.
		if (randomInt(10) > 2) {		// by passing 10 as the mod, we elect to only grab the last digit (0-9) of the hash!
			if (bigBoss.hp < character.attackDamage) {
				bigBoss.hp = 0;
			} else {
				bigBoss.hp = bigBoss.hp - character.attackDamage;
			}
			console.log("%s attacked boss. New boss hp: %s", character.name, bigBoss.hp);
		} else {
			console.log("%s missed!", character.name);
		}

		console.log("%s fight back %s...", bigBoss.name, character.name); 
		// Allow boss to attack player.
		if (randomInt(10) > 6) {
			if (character.hp < bigBoss.attackDamage) {
				character.hp = 0;
			} else {
				character.hp = character.hp - bigBoss.attackDamage;
			}
			console.log("Boss %s fight back %s. New character hp: %s", bigBoss.name, character.name, character.hp);
		} else {
			console.log("Boss missed!");
		}
	}

	// Users would be able to hit this function and get their NFT based on the
	// characterId they send in!
	function mintCharacterNFT(uint _characterIndex) external {
		// Get current tokenId (starts at 1 since we incremented in the constructor).
		uint256 newItemId = _tokenIds.current();

		// The magical function! Assigns the tokenId to the caller's wallet address.
		_safeMint(msg.sender, newItemId);

		// We map the tokenId => their character attributes. More on this in
		// the lesson below.
		nftHolderAttributes[newItemId] = CharacterAttributes({
			characterIndex: _characterIndex,
			name: defaultCharacters[_characterIndex].name,
			imageURI: defaultCharacters[_characterIndex].imageURI,
			hp: defaultCharacters[_characterIndex].hp,
			maxHp: defaultCharacters[_characterIndex].maxHp,
			attackDamage: defaultCharacters[_characterIndex].attackDamage,
			job: defaultCharacters[_characterIndex].job
		});

		console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

		// Keep an easy way to see who owns what NFT.
		nftHolders[msg.sender] = newItemId;

		// Increment the tokenId for the next person that uses it.
		_tokenIds.increment();
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

		string memory strHp = Strings.toString(charAttributes.hp);
		string memory strMaxHp = Strings.toString(charAttributes.maxHp);
		string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

		string memory json = Base64.encode(
			abi.encodePacked(
				'{"name": "',
				charAttributes.name,
				' -- NFT #: ',
				Strings.toString(_tokenId),
				'", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
				charAttributes.imageURI,
				'", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}',
				', { "trait_type": "Attack Damage", "value": ', strAttackDamage,'}', 
				', { "trait_type": "Job", "value": "', charAttributes.job,'"}', 
				' ]}'
			)
		);

		string memory output = string(
			abi.encodePacked("data:application/json;base64,", json)
		);

		return output;
	}

	uint randNonce = 0; // this is used to help ensure that the algorithm has different inputs every time

	function randomInt(uint _modulus) internal returns(uint) {
		randNonce++;                                                     // increase nonce
		return uint(keccak256(abi.encodePacked(block.timestamp,                      // an alias for 'block.timestamp'
												msg.sender,               // your address
												randNonce))) % _modulus;  // modulo using the _modulus argument
	}
	
}