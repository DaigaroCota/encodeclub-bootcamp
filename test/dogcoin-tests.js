const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DogCoin Tests", function () {

  let accounts;
  let deployer;
  let dogcoin;
  let transferAmount;

  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  
  before(async () => {

    accounts = await ethers.getSigners();
    deployer = accounts[0];
    transferAmount = ethers.utils.parseUnits("5000", 18);

    const DogCoin = await ethers.getContractFactory("DogCoin");
    dogcoin = await DogCoin.deploy(
      "DogCoin",
      "DGC",
      18,
      ethers.utils.parseUnits("1000000", 18)
    );
  });

  it("Should add new holders to holders array", async () => {
    const oldHolders = await dogcoin.holders();
    await expect(oldHolders.length).to.eq(1);
    for (let index = 1; index <= 5; index++) {
      await dogcoin.transfer(accounts[index].address, transferAmount);
    }
    const newHolders = await dogcoin.holders();
    await expect(newHolders.length).to.eq(6);
  });

  it("Should remove holder from holders array", async () => {
    const oldHolders = await dogcoin.holders();
    await expect(oldHolders.length).to.eq(6);
    for (let index = 1; index <= 5; index++) {
      await dogcoin.connect(accounts[index]).transfer(deployer.address, transferAmount);
    }
    const newHolders = await dogcoin.holders();
    await expect(newHolders.length).to.eq(1);
  });

  it("Should not have empty slots (zero address) in holder array", async () => {
    for (let index = 1; index <= 5; index++) {
      await dogcoin.transfer(accounts[index].address, transferAmount);
    }
    await dogcoin.connect(accounts[3]).transfer(deployer.address, transferAmount);
    const holderArray = await dogcoin.holders();
    for (let index = 0; index < holderArray.length; index++) {
      expect(holderArray[index]).to.not.equal(ZERO_ADDRESS);
    }
  });
});
