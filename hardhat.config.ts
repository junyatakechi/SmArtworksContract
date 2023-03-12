// マルチ環境変数ファイル
const dotenv = require("dotenv");
dotenv.config({override: true});
if(process.env.MODE){
  console.log("MODE:", process.env.MODE);
  dotenv.config({path: `.env.${process.env.MODE}`, override: true});
}

// 
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers"
import "@nomiclabs/hardhat-etherscan";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks:{
    "goerli": {
      url: `https://goerli.infura.io/v3/${process.env.INFRA_API_KEY}`,
      accounts: [process.env.GOERLI_PRIVATE_KEYS!],
    }
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: `${process.env.ETHERSCAN_API_KEY}`
  }
};

export default config;
