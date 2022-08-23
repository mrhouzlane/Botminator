const hre = require("hardhat");

async function main() {
  
  const PRICE = await hre.ethers.getContractFactory("PriceConsumerV3");
  const price= await PRICE.deploy();

  const Botminator = await hre.ethers.getContractFactory("PriceConsumerV3");
  const botminator= await Botminator.deploy();

  await price.deployed();
  await botminator.deployed();

  console.log('Price deployed to', price.address);
  const latestPrice = await price.getLatestPrice();
  console.log("Latest price:", latestPrice);
  console.log("Botminator deployed to", botminator.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});