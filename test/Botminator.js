const { ethers } = require("chai");
const { expect } = require("chai");
const hre = require("hardhat");
const { experimentalAddHardhatNetworkMessageTraceHook } = require("hardhat/config");


describe("Botminator", function() {

  let Botminator, botminatorContract, owner, addr1, addr2, addr3, addrs
  beforeEach(async function () {
    Botminator = await hre.ethers.getContractFactory("botminatorVault");
    [owner, addr1, addr2, addr3, ...addrs] = await hre.ethers.getSigners();
    const router='0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'; 
    botminatorContract = await Botminator.deploy(router)
    console.log("deployed to :", botminatorContract.address)
    //uniswapRouter =  hre.ethers.getContractFactory("IUniswapV2Router02");
  });

  describe('Deployment', function() {
    it('Should deploy to the right router', async function () {
     // const router ='0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'; 
    })
  });


  describe('Hedger', function() {
    it('Should return the right price feed', async function () {
      const PRICE = await hre.ethers.getContractFactory("PriceConsumerV3");
      const price= await PRICE.deploy();
      await price.deployed();
      console.log('Price deployed to', price.address);
      // const latestPrice = await price.getLatestPrice();
      // console.log("Latest price:", latestPrice);
    })
  });




})



