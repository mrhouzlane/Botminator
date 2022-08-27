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
    botminatorContract = await Botminator.deploy()
    console.log("deployed to :", botminatorContract.address)
  });

 
  describe('HedgerRoute1', function() {
    it('Should return the right price feed', async function () {
      const PRICE = await hre.ethers.getContractFactory("PriceConsumerV3");
      const price= await PRICE.deploy();
      await price.deployed();
      console.log('Price deployed to', price.address);
      const aggregatorV3InterfaceABI = [{ "inputs": [], "name": "decimals", "outputs": [{ "internalType": "uint8", "name": "", "type": "uint8" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "description", "outputs": [{ "internalType": "string", "name": "", "type": "string" }], "stateMutability": "view", "type": "function" }, { "inputs": [{ "internalType": "uint80", "name": "_roundId", "type": "uint80" }], "name": "getRoundData", "outputs": [{ "internalType": "uint80", "name": "roundId", "type": "uint80" }, { "internalType": "int256", "name": "answer", "type": "int256" }, { "internalType": "uint256", "name": "startedAt", "type": "uint256" }, { "internalType": "uint256", "name": "updatedAt", "type": "uint256" }, { "internalType": "uint80", "name": "answeredInRound", "type": "uint80" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "latestRoundData", "outputs": [{ "internalType": "uint80", "name": "roundId", "type": "uint80" }, { "internalType": "int256", "name": "answer", "type": "int256" }, { "internalType": "uint256", "name": "startedAt", "type": "uint256" }, { "internalType": "uint256", "name": "updatedAt", "type": "uint256" }, { "internalType": "uint80", "name": "answeredInRound", "type": "uint80" }], "stateMutability": "view", "type": "function" }, { "inputs": [], "name": "version", "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }], "stateMutability": "view", "type": "function" }]
      const SANDUSD = "0x3D49406EDd4D52Fb7FFd25485f32E073b529C924" // SAND/USD
      const USDTUSD = "0x0A6513e40db6EB1b165753AD52E80663aeA50545" // USDT/USD
      const provider = new hre.ethers.providers.JsonRpcProvider("https://rpc.ankr.com/polygon")
      const getPriceSAND = new hre.ethers.Contract(SANDUSD, aggregatorV3InterfaceABI, provider)
      const getPriceUSDT = new hre.ethers.Contract(USDTUSD, aggregatorV3InterfaceABI, provider)
      await getPriceSAND.latestRoundData()
        .then((roundData) => {
          // Do something with roundData
          let priceInHex = roundData.answer._hex;
          const hexToDecimal = hex => parseInt(hex, 16)
          const price = hexToDecimal(priceInHex)
          console.log(`latest price of SAND: ${price * 10**-8} USD`);
        })

      await getPriceUSDT.latestRoundData()
      .then((roundData) => {
        // Do something with roundData
        let priceInHex = roundData.answer._hex;
        const hexToDecimal = hex => parseInt(hex, 16)
        const price = hexToDecimal(priceInHex)
        console.log(`latest price of USDT: ${price * 10**-8} USD`);
      })

    })

    it('Should run the function', async function () {

      // const overrides = {value: hre.ethers.utils.parseEther("0.1")};
      // await botminatorContract.connect(owner).transferLink(overrides);
      const link = await hre.ethers.getContractAt("IERC20", "0x326C977E6efc84E512bB9C30f76E30c160eD06FB");
      await link.connect(owner).approve(botminatorContract.address, 2);
      const bool = await botminatorContract.connect(owner).transferLink()
      // console.log(bool);



    })
  });




})



