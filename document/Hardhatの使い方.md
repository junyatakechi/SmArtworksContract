Hardhatの使い方.md

# コマンド
- ローカルネット起動
    - npx hardhat node
- ローカルでスクリプト実行
    -  npx hardhat run --network localhost scripts/local/foo.ts
- テストネットデプロイ
  - `hardhat.config.ts`にネットワーク情報を入れる。
  - npx hardhat run --network goerli scripts/deploy.ts
- Verify(etherscan)
  - npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS ARGUMENTS_OF_CONSTRUCROR