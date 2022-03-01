const { expect } = require("chai");
const { ethers } = require("hardhat");

const DEBUG = false;

describe("Proposal Factory Tests", function () {

  let provider;
  let accounts;
  let deployer;
  let factory;

  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  
  before(async () => {

    provider = ethers.getDefaultProvider("http://localhost:8545");
    accounts = await ethers.getSigners();
    deployer = accounts[0];

    const ProposalFactory = await ethers.getContractFactory("ProposalFactory");
    factory = await ProposalFactory.deploy();
  });

  it("Should deploy a Proposal Contract from factory", async () => {
    await factory.createProposal(
      [],
      accounts[1].address,
      await provider.getBlockNumber(),
      5,
      5
    );

    const listedProposals = await factory.getListedProposals();
    expect(listedProposals.length).to.eq(1);

    const deployedAddress = await factory.deployedProposals(listedProposals[0]);

    if (DEBUG) {
      console.log("deployedAddress", deployedAddress);
    } 
  });
});
