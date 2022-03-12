pragma solidity >0.5.4;

interface ERC777 {
    function getName() external view returns (string memory);
    function getSymbol() external view returns (string memory);
    function getTotalSupply() external view returns (uint);
    function balanceOf(address holder) external view returns (uint);
    function getGranularity() external view returns (uint);

    function getDefaultOperators() external view returns (address[] memory);
    function isOperatorFor(
        address operator,
        address holder
    ) external view returns (bool);
    function authorizeOperator(address operator) external;
    function revokeOperator(address operator) external;

    function send(address to, uint amount, bytes calldata data) external;
    function operatorSend(
        address from,
        address to,
        uint amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    function burn(uint amount, bytes calldata data) external;
    function operatorBurn(
        address from,
        uint amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;

    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint amount,
        bytes data,
        bytes operatorData
    );
    event Burned(
        address indexed operator,
        address indexed from,
        uint amount,
        bytes data,
        bytes operatorData
    );
    event AuthorizedOperator(
        address indexed operator,
        address indexed holder
    );
    event RevokedOperator(address indexed operator, address indexed holder);
}