const { ethers } = require("chai");
const { expect } = require("chai");
const hre = require("hardhat");
const { experimentalAddHardhatNetworkMessageTraceHook } = require("hardhat/config");


describe("Botminator", function() {

  let MoodyLink, moodyLinkContract, owner, addr1, addr2, addr3, addrs
  beforeEach(async function () {
    MoodyLink = await hre.ethers.getContractFactory("MoodyLink");
    [owner, addr1, addr2, addr3, ...addrs] = await hre.ethers.getSigners();
    moodyLinkContract = await MoodyLink.deploy()
  });

  describe('Deployment', function() {
    it('Should deploy the contracts', async function () {
      expect(await moodyLinkContract.owner()).to.equal(owner.address)
    })
  });

})



