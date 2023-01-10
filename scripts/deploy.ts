import { ethers } from "hardhat";

//
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  //
  const MinimalERC721 = await ethers.getContractFactory("MinimalERC721");
  console.log("deploying....");
  const contract = await MinimalERC721.deploy(
    "ERC721_TEST", 
    "ERCT",
    "ipfs://QmRhg78X5sL127UV8pqbd8axJo2mnRhf2hYeFLbngvNtPA/"
  );
  await contract.deployed();
  console.log("deployed to: ", contract.address);
}

// 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
