import { ethers } from "hardhat";

// https://eips.ethereum.org/EIPS/eip-5289
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  //
  const fact = await ethers.getContractFactory("ERC5289Library");
  console.log("deploying....");
  const contract = await fact.deploy();
  await contract.deployed();
  console.log("deployed to: ", contract.address);
}

// 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
