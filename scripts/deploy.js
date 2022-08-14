const hre = require("hardhat");

async function main() {
  
  //const SaintEthAmount = hre.ethers.utils.parseEther("0.1");

  const MoodyLink = await hre.ethers.getContractFactory("SaintEth");
  const moodyLink= await MoodyLink.deploy(10185);

  await moodyLink.deployed();

  console.log("Saint Eth", moodyLink.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});