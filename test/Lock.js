const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("APIConsumer Contract", function () {
  let apiConsumer, deployer, user;

  beforeEach(async () => {
    [deployer, user] = await ethers.getSigners();

    const APIConsumer = await ethers.getContractFactory("APIConsumer");
    apiConsumer = await APIConsumer.deploy();
    await apiConsumer.deployed();
  });

  it("Should deploy the contract correctly", async function () {
    expect(apiConsumer.address).to.properAddress;
  });

  it("Should request volume data", async function () {
    const tx = await apiConsumer.requestVolumeData(
      "https://example.com/api",
      "your-api-key",
      "match123",
      "data.path"
    );
    await tx.wait();

    expect(tx.hash).to.be.a("string");
  });

  it("Should allow users to set their selected team", async function () {
    await apiConsumer.setUserSelectedTeam(1, ethers.utils.parseEther("1"));

    const userChoice = await apiConsumer.userChoices(deployer.address);
    expect(userChoice).to.equal(1);
  });
});
