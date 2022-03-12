pragma solidity >0.5.4;
import "../contracts/Market.sol";
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";


contract TestMarket {
    Market market = Market(DeployedAddresses.Market());

    function testGetTokens() public {
        Assert.equal(market.getBalance(msg.sender), 10000, "Initial tokens weren't transferred");
    }

    function testGetThings() public {
        Assert.equal(market.getThingsLength(), 0, "Initial array isn't empty");
    }

    function testCreateThing() public {
        market.createThing('qwerty');
        Assert.equal(market.getThingsLength(), 1, "Thing wasn't created");
    }
}
