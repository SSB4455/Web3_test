// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Helper we wrote to encode in Base64
import "./libraries/Base64.sol";

// Our contract inherits from ERC721, which is the standard NFT contract!
contract MyNFTsBasedGame is ERC721, Ownable {
	// We'll hold our character's attributes in a struct. Feel free to add
	// whatever you'd like as an attribute! (ex. defense, crit chance, etc).
	struct CharacterAttributes {
		uint tokenId;
		string name;
		string imageURI;
		uint hp;
		uint maxHp;
		uint attackDamage;
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
	mapping(uint256 => CharacterAttributes) public characterAttributes;

	event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
	event Injuried_Boss(uint newBossHp);
	event Injuried_Character(uint tokenId, uint newPlayerHp);

	constructor(
		string[] memory characterNames,
		string[] memory characterImageURIs,
		uint[] memory characterHps,
		uint[] memory characterAttackDmgs,
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
				tokenId: i,
				name: characterNames[i],
				imageURI: characterImageURIs[i],
				hp: characterHps[i],
				maxHp: characterHps[i],
				attackDamage: characterAttackDmgs[i]
			}));

			CharacterAttributes memory c = defaultCharacters[i];
			
			// Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
			console.log("Done initializing %s w/ img %s", c.name, c.imageURI);
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

	function addCharacterAttributes(
		string memory characterName,
		string memory characterImageURI,
		uint characterHp,
		uint characterAttackDmg)
        public onlyOwner
    {
		defaultCharacters.push(CharacterAttributes({
			tokenId: defaultCharacters.length,
			name: characterName,
			imageURI: characterImageURI,
			hp: characterHp,
			maxHp: characterHp,
			attackDamage: characterAttackDmg
		}));
	}

	function getUserHasCharacters() public view returns (CharacterAttributes[] memory) {
		uint256 balance = balanceOf(msg.sender);
		CharacterAttributes[] memory userCharacters = new CharacterAttributes[](balance);
		uint ii = 0;

		for(uint i = 0; i < _tokenIds.current(); i += 1) {
			if (ownerOf(i) == msg.sender) {
				CharacterAttributes storage character = characterAttributes[i];
				userCharacters[ii] = CharacterAttributes({
					tokenId: character.tokenId,
					name: character.name,
					imageURI: character.imageURI,
					hp: character.hp,
					maxHp: character.maxHp,
					attackDamage: character.attackDamage
				});
				ii += 1;
			}
		}
		
		return userCharacters;
	}

	function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
		return defaultCharacters;
	}

	function getBigBoss() public view returns (BigBoss memory) {
		return bigBoss;
	}

	function attackBoss(uint256 tokenId) public {
		// 必须使用自己的Character
		require(ownerOf(tokenId) == msg.sender);
		CharacterAttributes storage character = characterAttributes[tokenId];

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
		if (randomInt(10) > 1) {		// by passing 10 as the mod, we elect to only grab the last digit (0-9) of the hash!
			if (bigBoss.hp < character.attackDamage) {
				bigBoss.hp = 0;
			} else {
				bigBoss.hp = bigBoss.hp - character.attackDamage;
			}
			console.log("%s attacked boss. Boss hp: %s", character.name, bigBoss.hp);
		} else {
			console.log("%s missed!", character.name);
		}

		console.log("%s fight back %s...", bigBoss.name, character.name); 
		// Allow boss to attack player.
		if (randomInt(10) > 2) {
			if (character.hp < bigBoss.attackDamage) {
				character.hp = 0;
			} else {
				character.hp = character.hp - bigBoss.attackDamage;
			}
			console.log("Boss %s fight back, %s's hp: %s", bigBoss.name, character.name, character.hp);
		} else {
			console.log("Boss missed!");
		}

		emit Injuried_Boss(bigBoss.hp);
		emit Injuried_Character(tokenId, character.hp);
	}

	function reviveBoss() public onlyOwner {
		bigBoss.hp = bigBoss.maxHp;
		emit Injuried_Boss(bigBoss.hp);
	}

	function reviveCharacter(uint tokenId) public onlyOwner {
		CharacterAttributes storage character = characterAttributes[tokenId];
		character.hp = character.maxHp;
		emit Injuried_Character(tokenId, character.hp);
	}

	// Users would be able to hit this function and get their NFT based on the
	// characterId they send in!
	function mintCharacterNFT(uint _characterIndex) external {
		require(_characterIndex < defaultCharacters.length);

		// Get current tokenId (starts at 1 since we incremented in the constructor).
		uint256 newItemId = _tokenIds.current();

		// The magical function! Assigns the tokenId to the caller's wallet address.
		_safeMint(msg.sender, newItemId);

		// We map the tokenId => their character attributes. More on this in
		// the lesson below.
		uint hp = getRandomAttributes(defaultCharacters[_characterIndex].maxHp);
		characterAttributes[newItemId] = CharacterAttributes({
			tokenId: newItemId,
			name: defaultCharacters[_characterIndex].name,
			imageURI: defaultCharacters[_characterIndex].imageURI,
			hp: hp,
			maxHp: hp,
			attackDamage: getRandomAttributes(defaultCharacters[_characterIndex].attackDamage)
		});

		console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

		// Increment the tokenId for the next person that uses it.
		_tokenIds.increment();

		emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
	}

	function getRandomAttributes(uint source) private returns (uint) {
		uint ff = source / 5;
		ff = randomInt(ff);
		if (ff % 2 == 0) {
			if ((source + ff / 2) > source) {
				source += ff / 2;
			}
		} else {
			if ((source - ff / 2) < source && (source - ff / 2) > 3) {
				source -= ff / 2;
			}
		}
		return source;
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		CharacterAttributes memory charAttributes = characterAttributes[_tokenId];

		string memory strHp = Strings.toString(charAttributes.hp);
		string memory strMaxHp = Strings.toString(charAttributes.maxHp);
		string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

		string memory json = Base64.encode(
			abi.encodePacked(
				'{"name": "',
				charAttributes.name,
				' -- NFT #: ',
				Strings.toString(_tokenId),
				'", "description": "This is an frends NFT test.", "image": "',
				charAttributes.imageURI,
				'", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}',
				', { "trait_type": "Attack Damage", "value": ', strAttackDamage,'} ]}'
			)
		);

		string memory output = string(
			abi.encodePacked("data:application/json;base64,", json)
		);

		return output;
	}

	uint randNonce = 0; // this is used to help ensure that the algorithm has different inputs every time

	function randomInt(uint _modulus) internal returns (uint) {
		randNonce++;                                                     // increase nonce
		return uint(keccak256(abi.encodePacked(block.timestamp,                      // an alias for 'block.timestamp'
												msg.sender,               // your address
												randNonce))) % _modulus;  // modulo using the _modulus argument
	}
	
}