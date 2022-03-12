pragma solidity >0.5.4;
pragma experimental ABIEncoderV2;

import { Token777 } from './Token777.sol';

contract Market {
    Token777 token = new Token777("Token777", "T777", 5000000, 1, address(this));

    struct Thing {
        string name;
        address owner;
        bool isSelling;
        uint price;
    }

    Thing[] things;

    modifier onlyOwner(string memory name) {
        uint index = uint(indexOfThing(name));
        require(things[index].owner == msg.sender, 'You are not owner');
        _;
    }

    modifier thingExists(string memory name) {
        int index = indexOfThing(name);
        require(index != int(-1), 'This thing doesnt exist');
        _;
    }

    constructor() public {
        token.send(msg.sender, 10000, '');
    }

    function getMyBalance() external view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    function getBalance(address owner) external view returns(uint) {
        return token.balanceOf(owner);
    }

    function transferTokens(address to, uint amount) external{
        token.operatorSend(msg.sender, to, amount, '', '');
    }

    function indexOfThing(string memory name) internal view returns(int){
        for (uint ind = 0; ind < things.length; ind++) {
            if (keccak256(abi.encodePacked(things[ind].name)) == keccak256(abi.encodePacked(name))) {
                return int(ind);
            }
        }
        return int(-1);
    }

    function createThing(string calldata name) external {
        require(indexOfThing(name) == int(-1), 'This thing already exists');
        things.push(Thing(name, msg.sender, false, 0));
    }

    function burnThing(string calldata name) external onlyOwner(name) thingExists(name) {
        uint index = uint(indexOfThing(name));
        for (uint ind = index; index < things.length-1; ind++) {
            things[ind] = things[ind+1];
        }
        delete things[things.length-1];
        things.length--;
    }

    function sellThing(string calldata name, uint price) external onlyOwner(name) thingExists(name){
        uint index = uint(indexOfThing(name));
        things[index].price = price;
        things[index].isSelling = true;
    }

    function buyThing(string calldata name) external thingExists(name){
        uint index = uint(indexOfThing(name));
        require(things[index].isSelling, 'This thing is not selling');
        require(token.balanceOf(msg.sender) >= things[index].price, 'You dont have enough money');
        token.operatorSend(msg.sender, things[index].owner, things[index].price, '', '');
        things[index].owner = msg.sender;
        things[index].isSelling = false;
    }

    function getThings() external view returns(Thing[] memory) {
        return things;
    }

    function getThingsLength() external view returns(uint) {
        return things.length;
    }

    function getThing(string calldata name) external view thingExists(name) returns(Thing memory) {
        uint index = uint(indexOfThing(name));
        return things[index];
    }

}
