import { ethers } from "hardhat";

//
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  //
  const MinimalERC721 = await ethers.getContractFactory("Applicationable");
  console.log("deploying....");
  const contract = await MinimalERC721.deploy();
  await contract.deployed();
  console.log("deployed to: ", contract.address);
}

// 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
