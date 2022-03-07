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

    provider = ethers.getDefaultProvider();
    accounts = await ethers.getSigners();
    deployer = accounts[0];

    const ProposalInitializable = await ethers.getContractFactory("ProposalInitializable");
    proposalImplementation = await ProposalInitializable.deploy();
    const currentblockNum = await provider.getBlockNumber();

    // Initialize implementation so that that cannot be modified.
    await proposalImplementation.initialize(
      0,
      [],
      ZERO_ADDRESS,
      currentblockNum,
      currentblockNum + 1,
      currentblockNum + 2
    );

    const ProposalCloneFactory = await ethers.getContractFactory("ProposalCloneFactory");
    factory = await ProposalCloneFactory.deploy();

    // Set the implementation that will be cloned.
    await factory.setProposalImplementation(proposalImplementation.address);
  });

  it("Should deploy a clone proxy proposal contract from factory", async () => {
    const currentblockNum = await provider.getBlockNumber();
    await factory.createProposalClone(
      [],
      accounts[1].address,
      currentblockNum,
      currentblockNum + 5,
      currentblockNum + 10
    );

    const listedProposals = await factory.getListedProposals();
    expect(listedProposals.length).to.eq(1);

    const deployedAddress = await factory.deployedProposals(listedProposals[0]);

    if (DEBUG) {
      console.log("deployedAddress", deployedAddress);
    }
  });
});
