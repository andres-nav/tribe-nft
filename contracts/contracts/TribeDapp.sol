// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ITribeDapp.sol";
import "./ITribeDappErrors.sol";

contract TribeDapp is Ownable, ERC1155, ITribeDapp, ITribeDappErrors {

    struct Tribe {
	address owner;
	uint256 priceToJoin;
	uint256 maxCapacity;
	uint256 capacity;
	string uri;
    }

    // Mapping from token ID to tribes
    mapping(uint256 => Tribe) private _tribes;

    uint256 private _priceNewTribe;
    uint256 private _maxId;

    constructor (uint256 priceNewTribe) ERC1155("") {
	_priceNewTribe = priceNewTribe;
	_maxId = 0;
    }

    modifier tribeExists(uint256 id) {
	require(!_isTribeEmpty(id));
	_;
    }

    modifier onlyTribeOwner(uint256 id) {
	require(msg.sender == _tribes[id].owner);
	_;
    }

    function setPriceNewTribe(uint256 priceNewTribe) public onlyOwner {
	_priceNewTribe = priceNewTribe;
    }

    function getPriceNewTribe() public view returns(uint256) {
	return _priceNewTribe;
    }

    function getMaxId() public view returns(uint256) {
	return _maxId;
    }

    function _isTribeEmpty(uint256 id) internal view returns(bool) {
	return _tribes[id].owner == address(0);
    }

    function createTribe(uint256 priceToJoin, uint256 maxCapacity, string memory uri) public payable returns(uint256) {
	if (msg.value != _priceNewTribe) {
	    revert TribeDappWrongPayment(msg.value, _priceNewTribe);
	}

	_maxId++;

	_tribes[_maxId] = Tribe(msg.sender, priceToJoin, maxCapacity, 0, uri); 

	emit EditTribe(_maxId);

	return _maxId;
    }

    function deleteTribe(uint256 id) public tribeExists(id) onlyTribeOwner(id) {
	_tribes[id] = Tribe(address(0), 0, 0, 0, "");
	emit EditTribe(id);
    }

    function getTribe(uint256 id) public view tribeExists(id) returns(address owner, uint256 priceToJoin, uint256 maxCapacity, uint256 capacity, string memory uri) {
	Tribe memory tribe = _tribes[id];
	owner = tribe.owner;
	priceToJoin = tribe.priceToJoin;
	maxCapacity = tribe.maxCapacity;
	capacity = tribe.capacity;
	uri = tribe.uri;
    }

    function setOwnershipToTribe(uint256 id, address newOwner) public tribeExists(id) onlyTribeOwner(id) {
	_tribes[id].owner = newOwner;

	emit EditTribe(id);
    }

    function setPriceToJoinToTribe(uint256 id, uint256 newPriceToJoin) public tribeExists(id) onlyTribeOwner(id) {
	_tribes[id].priceToJoin = newPriceToJoin;

	emit EditTribe(id);
    }

    function setMaxCapacityToTribe(uint256 id, uint256 newMaxCapacity) public tribeExists(id) onlyTribeOwner(id) {
	Tribe memory tribe = _tribes[id];
	if (tribe.capacity > newMaxCapacity) {
	    revert TribeDappMaxCapacitySmall(tribe.capacity, newMaxCapacity); 
	}

	tribe.maxCapacity = newMaxCapacity;
	emit EditTribe(id);
    }

    function setUriToTribe(uint256 id, string memory uri) public tribeExists(id) onlyTribeOwner(id) {
	_tribes[id].uri = uri;

	emit EditTribe(id);
    }

    function mint(uint256 id) public payable tribeExists(id) {
	Tribe memory tribe = _tribes[id];
	if (tribe.capacity >= tribe.maxCapacity) {
	    revert TribeDappTribeFull();
	}

	if (msg.value != tribe.priceToJoin) {
	    revert TribeDappWrongPayment(msg.value, tribe.priceToJoin);
	}

	//check if it already has one

	_mint(msg.sender, id, 1, "");
	tribe.capacity++;
    }

    //limit to only one

    function burn(uint256 id) public tribeExists(id) {
	
    }

    function withdraw() public onlyOwner {
    }

    function withdrawTribe() public {
	
    }
}
