const { ethers } = require("chai");
const { expect } = require("chai");
const hre = require("hardhat");
const { experimentalAddHardhatNetworkMessageTraceHook } = require("hardhat/config");

describe("Botminator1", function() {

  let Botminator, botminatorContract, owner, addr1, addr2, addr3, addrs
  beforeEach(async function () {
    Botminator = await hre.ethers.getContractFactory("botminatorVault");
    [owner, addr1, addr2, addr3, ...addrs] = await hre.ethers.getSigners();
    // const router='0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'; 
    botminatorContract = await Botminator.deploy()
    console.log("deployed to :", botminatorContract.address)
  });



  it('do the math conversion for getPriceRate', async function () {
    //example for 50$ : 
    const usd = 50 * (10**18) 
    const sand = 927900000000000000
    const result= usd / sand 
    console.log(result) 
    // OK 

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

      /*
       * @dev: contract addresses used in contract
       */ 

    
      const routerSushiswap = "0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506"; // POLYGON
      const routerQuickswap = "0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32"; // POLYGON
      const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // POLYGON
      const Thether = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F"; //POLYGON
      const SANDAddress = "0xC6d54D2f624bc83815b49d9c2203b1330B841cA0"; //POLYGON
      const LINKAddress = "0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39"; //POLYGON
      const dai = await hre.ethers.getContractAt("IERC20", Thether );
      console.log(dai);
      const sand = await hre.ethers.getContractAt("IERC20", SANDAddress);
      const link = await hre.ethers.getContractAt("IERC20", LINKAddress);

      /*
       * @dev: convert 0.1 ETH to each token for testing
       */      
      const validDeadLine = "999999999999"
      const etherAmountIn = hre.ethers.utils.parseEther("1")
      const sushi = await hre.ethers.getContractAt("IUniswapV2Router02", routerSushiswap);
      const daiAmountOut = (await sushi.getAmountsOut(etherAmountIn, [WETHAddress, DAIAddress]))[1]
      const sandAmountOut = (await sushi.getAmountsOut(etherAmountIn, [WETHAddress, SANDAddress]))[1]
      const linkAmountOut = (await sushi.getAmountsOut(etherAmountIn, [WETHAddress, LINKAddress]))[1]


      await sushi.swapExactETHForTokens(daiAmountOut, [WETHAddress, DAIAddress], owner.address, validDeadLine, {value: etherAmountIn})
      await sushi.swapExactETHForTokens(sandAmountOut, [WETHAddress, SANDAddress], owner.address, validDeadLine, {value: etherAmountIn})
      const tx = await sushi.swapExactETHForTokens(linkAmountOut, [WETHAddress, LINKAddress], owner.address, validDeadLine, {value: etherAmountIn})
      // console.log(tx);
      await sand.approve(botminatorContract.address, sandAmountOut);
      await link.approve(botminatorContract.address, linkAmountOut);
      await dai.approve(botminatorContract.address, daiAmountOut);
      // await sushi.swapExactTokensForTokens(amountIn, SANDOut, [SANDAddress, DAIAddress], owner.address, deadline)

      await botminatorContract.HedgerRoute1(daiAmountOut);
 

      const overrides = {value: hre.ethers.utils.parseEther("0.1")};
      await botminatorContract.connect(owner).transferLink(overrides);
      // const whaleAddress = "0x7B0419581Eb2e34B4D3Bfc1689f1Bd855d364d9D";
      // await network.provider.request({
      //   method: "hardhat_impersonateAccount",
      //   params: [whaleAddress],
      // });
      // const whale = await hre.ethers.getSigner(whaleAddress);
      // await link.connect(whale).transfer("0x4593ed9CbE6003e687e5e77368534bb04b162503", hre.ethers.utils.parseEther("100"));
      // await link.connect().approve(botminatorContract.address, "10000000000000000000");
      // await botminatorContract.connect(owner).transferLink()

      // const dai = await hre.ethers.getContractAt("IERC20", "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889");
      // await dai.connect(owner).approve(botminatorContract.address, "500000000000000000");

      // const sand = await hre.ethers.getContractAt("IERC20", "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa");
      // await sand.connect(owner).approve(botminatorContract.address, "3478880327338707");

      // await botminatorContract.HedgerRoute1("500000000000000000");
      // console.log(bool);



    })
  });




})



