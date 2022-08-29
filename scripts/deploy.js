const hre = require("hardhat");

async function main() {
  
  // const PRICE = await hre.ethers.getContractFactory("PriceConsumerV3");
  // const price= await PRICE.deploy();
  const Botminator = await hre.ethers.getContractFactory("botminatorVault");
  const botminator= await Botminator.deploy();
  await botminator.deployed();


  const BotminatorKeeper = await hre.ethers.getContractFactory("BominatorKeeper");
  const botminatorKeeper= await BotminatorKeeper.deploy(botminator.address, );
  await botminatorKeeper.deployed();


  // await price.deployed();

  // console.log('Price deployed to', price.address);
  // const latestPrice = await price.getLatestPrice();
  // console.log("Latest price:", latestPrice);
  console.log("Botminator deployed to", botminator.address)
  console.log("BotminatorKeeper deployed to", botminatorKeeper.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});