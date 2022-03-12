const Market = artifacts.require('Market')
let assert = require('chai').assert
let expect = require('chai').expect

// Для того, чтобы проверять revert асинхронных функций
const truffleAssert = require('truffle-assertions');

contract('Market', (accounts) => {
  let market;

  before( async () => {
    market = await Market.deployed();
  })

  describe('when we deployed contract', () => {
    it('should be 10000 tokens in this address', async function() {
      const tokens = await market.getMyBalance();
      assert.equal(tokens.valueOf().toNumber(), 10000, "there is no 10000 tokens in this address");
    })
    it('should return empty array', async function () {
      const things = await market.getThings();
      assert.isEmpty(things, "Some things are created");
    })
  });

  describe('when we create new thing', () => {
    it('should create new thing in array', async function () {
      // Создадим вещь для 3-го аккаунта
      await market.createThing("thing", {from: accounts[2]});
      const things = await market.getThings();
      expect(things, "Array size isn't equal to 1").to.have.lengthOf(1);
      expect(things[0].name, "Thing's name in array is incorrect").to.be.equal("thing");
      // Проверим функцию getThing
      expect((await market.getThing("thing")).name, "Thing's name in array is incorrect").to.be.equal("thing");
    })
  })

  describe('when we sell thing', () => {
    it('should be revert if we try to sell thing not from owner', async function () {
      // Владелец - accounts[2]
      await truffleAssert.reverts(market.sellThing('thing', 20, {from: accounts[1]}),
          truffleAssert.ErrorType.REVERT,
          "There's no revert with non owner account");
    })
    it('should change isSelling and price value', async function () {
      await market.sellThing('thing', 20, {from: accounts[2]});
      const thing = await market.getThing('thing');
      expect(thing.isSelling, "isSelling value didn't change").to.be.true;
      expect(thing.price).to.be.equal('20', "price value didn't change");
    })
  })

  describe('when we buy the the thing', () => {
    it('should be revert if isSelling value is false', async function () {
      await market.createThing('newThing');
      await truffleAssert.reverts(market.buyThing('newThing'),
          truffleAssert.ErrorType.REVERT,
          "There's no revert with non selling thing");
    })

    it('should be revert if buyer doesnt have enough tokens', async function () {
      // У accounts[3] 0 токенов, а thing стоит 20 токенов
      await truffleAssert.reverts(market.buyThing('thing', {from: accounts[3]}),
          truffleAssert.ErrorType.REVERT,
          "There's no revert when buyer doesn't have enough tokens");
    })

    it('should transfer tokens', async function () {
      const ownerBalance = await market.getMyBalance({from: accounts[2]});
      const buyerBalance = await market.getMyBalance();
      // Thing стоит 20 токенов
      market.buyThing('thing');
      const newOwnerBalance = await market.getMyBalance({from: accounts[2]});
      const newBuyerBalance = await market.getMyBalance();
      expect(newOwnerBalance.valueOf().toNumber()).to.be.equal(ownerBalance.valueOf().toNumber()+20,
          "Owner didn't get right amount of tokens");
      expect(newBuyerBalance.valueOf().toNumber()).to.be.equal(buyerBalance.valueOf().toNumber()-20,
          "Buyer didn't lose right amount of tokens");
    })

    it('should change thing owner', async function () {
      const thing = await market.getThing('thing');
      expect(thing.owner).to.be.equal(accounts[0], "New owner of thing isn't right");
    })

    it('should change isSelling value on false', async function () {
      const thing = await market.getThing('thing');
      expect(thing.isSelling, "isSelling value didn't change to false").to.be.false;
    })
  })

  describe('when we burn thing', () => {
    it('should be revert if non owner trying to burn', async function () {
      await truffleAssert.reverts(market.burnThing('thing', {from: accounts[3]}),
          truffleAssert.ErrorType.REVERT,
          "There's no revert when non owner trying to burn thing");
    })
  })
})