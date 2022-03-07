const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("DogCoin Upgradeable Tests", function () {

  let accounts;
  let deployer;
  let dogcoin;
  
  before(async () => {
    
    accounts = await ethers.getSigners();
    deployer = accounts[0];

    const DogCoinV1 = await ethers.getContractFactory("DogCoinUpgradeableV1");
    dogcoin = await upgrades.deployProxy(
      DogCoinV1,
      [
        "DogCoin",
        "DGC",
        18,
        ethers.utils.parseUnits("1000000", 18)
      ],
      { kind: 'uups' }
    );
  });

  it("Succesfully upgrade contract", async () => {
    const currentVersion = await dogcoin.version();
    expect(currentVersion).to.eq("1");
    const DogCoinV2 = await ethers.getContractFactory("DogCoinUpgradeableV2");
    dogcoin = await upgrades.upgradeProxy(
      dogcoin.address,
      DogCoinV2,
    );
    await dogcoin.confirmUpgrade();
    const newVersion = await dogcoin.version();
    expect(newVersion).to.eq("2");
  });

  it("Succesfully use new upgraded contract functionality", async () => {
    const coder = new ethers.utils.AbiCoder;
    const valueOfNewVariable = await dogcoin.getNewVariable();
    expect(valueOfNewVariable).to.eq(0);
    const change = 10;
    await dogcoin.changeNewVariable(change);
    const appliedNewVariable = await dogcoin.getNewVariable();
    expect(appliedNewVariable).to.eq(change); 
  });

});
