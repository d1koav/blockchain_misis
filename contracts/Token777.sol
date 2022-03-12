pragma solidity >0.5.4;

import { ERC777 } from './ERC777.sol';

contract Token777 is ERC777 {
    string internal name; // Полное название токена
    string internal symbol; // Символы токена
    uint internal granularity; // Кратность токенов
    uint internal totalSupply; // Общее кол-во токенов
    mapping(address => uint) internal balances;
    mapping(address => mapping(address => bool)) internal isAuth;
    mapping(address => mapping(address => bool)) internal isRevoked;
    address[] internal defaultOperators;
    mapping(address => bool) internal isDefault;

    constructor(string memory _name, string memory _symbol, uint _initSupply, uint _granularity, address _defaultOperator) public{
        name = _name;
        symbol = _symbol;

        defaultOperators.push(_defaultOperator);
        isDefault[_defaultOperator] = true;

        require(_granularity >= 1, "Granularity < 1");
        granularity = _granularity;

        require(_initSupply % _granularity == 0, "The number of tokens isn't a multiple of granularity");

        totalSupply = _initSupply;
        balances[msg.sender] = totalSupply;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    function getTotalSupply() public view returns (uint) {
        return totalSupply;
    }

    function getGranularity() external view returns (uint) {
        return granularity;
    }

    function balanceOf(address holder) external view returns (uint) {
        return balances[holder];
    }

    function getDefaultOperators() external view returns (address[] memory) {
        return defaultOperators;
    }

    function isOperatorFor(address operator, address holder) public view returns (bool) {
        return !isRevoked[holder][operator] && (isDefault[operator] || isAuth[holder][operator]);
    }

    function authorizeOperator(address operator) external {
        require(operator != msg.sender, "It's prohibited to auth the holder");
        isAuth[msg.sender][operator] = true;
        isRevoked[msg.sender][operator] = false;

        emit AuthorizedOperator(operator, msg.sender);
    }

    function revokeOperator(address operator) external {
        require(operator != msg.sender, "It's prohibited to revoke the right to be operator for yourself");
        isRevoked[msg.sender][operator] = true;

        emit RevokedOperator(operator, msg.sender);
    }

    function burn(uint amount, bytes calldata data) external {
        burnTokens(msg.sender, amount, data, data);
    }

    function operatorBurn(address from, uint amount, bytes calldata data, bytes calldata operatorData) external {
        require(isOperatorFor(msg.sender, from), "You aren't operator for this address");
        burnTokens(from, amount, data, operatorData);
    }

    function burnTokens(address from, uint amount, bytes memory data, bytes memory operatorData) internal {
        require(from != address(0), "It's prohibited to burn tokens in address 0");
        require(amount % granularity == 0, "The number of tokens to be burned must be a multiple of granularity");
        require(amount <= balances[from], "Not enough tokens to burn");

        balances[from] -= amount;
        totalSupply -= amount;

        emit Burned(msg.sender, from, amount, data, operatorData);
    }

    function send(address to, uint amount, bytes calldata data) external {
        sendTokens(msg.sender, to, amount, data, data);
    }

    function operatorSend(address from, address to, uint amount, bytes calldata data, bytes calldata operatorData) external{
        require(isOperatorFor(msg.sender, from),
        "You aren't operator for purpose address");
        sendTokens(from, to, amount, data, operatorData);
    }

    function sendTokens(address from, address to, uint amount, bytes memory data, bytes memory operatorData) internal {
        require(from != address(0), "Sender's address can't be equal to 0");
        require(to != address(0), "Recipient's address can't be equal to 0");
        require(amount <= balances[from], "You don't have enough tokens to send");
        require(amount % granularity == 0, "The number of tokens isn't a multiple of granularity");

        balances[from] -= amount;
        balances[to] += amount;

        emit Sent(msg.sender, from, to, amount, data, operatorData);
    }
}
