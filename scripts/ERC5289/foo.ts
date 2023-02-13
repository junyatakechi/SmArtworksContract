import { ethers } from "hardhat";

//
async function main() {
  const [deployer, alice] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  //
  const fact = await ethers.getContractFactory("ERC5289Library");
  console.log("deploying....");
  const contract = await fact.attach("0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9");

  // ライセンス文章登録
  const doc0 = await contract.registerDocument("https://sample.com");
  // console.log("doc0: ", doc0);

  // ライセンスIDからライセンス文章を参照。
  const doc0_url = await contract.legalDocument(0);
  console.log("legalDocument: ", doc0_url);

  // ライセンス文章に同意して署名する。
  await contract.connect(alice).signDocument(alice.address, 0);

  // ライセンスIDに対して、指定のアドレスが署名したかを確認し、署名した時間を返す。
  const timestamp = await contract.documentSignedAt(alice.address, 0);
  console.log("timestamp: ", timestamp);

}

// 
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
