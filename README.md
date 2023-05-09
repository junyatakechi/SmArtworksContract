Bright Licensable Work NFT

# 目標
- 音楽などのNFTのライセンスの明確化。
- 許諾申請の自動化。
- ライセンス使用料の透明化。


# 許諾フロー
```mermaid
sequenceDiagram
    actor User;
    participant レジスター;
    Note over レジスター: アーティスト毎
    participant NFTスマコン;
    Note over NFTスマコン: 作品毎
    User ->>+ レジスター: ガイドラインと作品権利の取得(作品ID)
    レジスター ->> NFTスマコン: 権利情報を取得
    NFTスマコン -->> レジスター: (使用料, 支払い先リスト)
    レジスター -->>- User: (ガイドラインURL, バージョン, 作品権利情報)
    User -->> User: ガイドライン署名(ガイドライン文章)
    User ->>+ レジスター: 申請(作品ID, 文章署名, バージョン, ETH)
    レジスター ->>+ NFTスマコン: 作品情報の取得
    NFTスマコン -->>- レジスター: 
    レジスター --> レジスター: 申請内容・署名検証
    レジスター ->>- User: 発行<許諾SBT>
```
# ファンによる検証
```mermaid
sequenceDiagram
    actor ファン;
    actor 作品使用者;
    participant レジスター;
    Note over レジスター: アーティスト毎
    ファン ->> 作品使用者: 発見
    作品使用者 -->> ファン: 許諾SBTの提示
    ファン ->> レジスター: 許諾状況の確認(tokenId, 作品使用者情報)
    レジスター --> レジスター: 許諾内容の検証
    レジスター -->> ファン: 許諾状態(True or False)
```
# アーティストの登録作業
```mermaid
sequenceDiagram
    actor アーティスト;
    participant レジスター;
    participant NFTスマコン;
    Note over NFTスマコン: 作品毎
    Note over レジスター: アーティスト毎
    アーティスト ->> レジスター: ガイドライン登録(textURL, バージョン)
    アーティスト ->> NFTスマコン: 利用範囲と料金の設定
    アーティスト ->>+ レジスター: NFTスマコンの登録
    レジスター ->> NFTスマコン: 登録可能か?(address, IFの実装)
    NFTスマコン -->> レジスター: 合否
    レジスター -->>- アーティスト: 登録結果
```

# 開発環境
## 環境設定ファイル
- `.env`
- `.env.local`

## hardhat
- ローカルネット起動
    - npx hardhat node
- ローカルでスクリプト実行
    -  npx hardhat run --network localhost scripts/local/foo.ts
- テストネットデプロイ
  - `hardhat.config.ts`にネットワーク情報を入れる。
  - npx hardhat run --network goerli scripts/deploy.ts
- Verify(etherscan)
  - npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS ARGUMENTS_OF_CONSTRUCROR


## テストネットでデバッグ
- Goerliネットワーク
- デバッグ用アカウント
  - [!] 誰でも操作できるウォレットなので、取り扱い注意。
  - 公開アドレス：0xe757D1fB6A2841F7Cb9b74Aac491590eb77210b6
  - 秘密鍵：6074babd86f0cc13ecc3c4c6c78ff7b86962b90e2fe4e1a1771cc21c50b8c95e
  - メタマスクなどにインポートして使用する。
