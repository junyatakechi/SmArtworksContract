Bright Licensable Work NFT

# 目次
- [目次](#目次)
- [何を目指すのか？](#何を目指すのか)
  - [2次創作活動への壁を減らす](#2次創作活動への壁を減らす)
  - [ファンが2次創作を安心して好きになれるようする](#ファンが2次創作を安心して好きになれるようする)
- [解決されなくても良しとする問題](#解決されなくても良しとする問題)
- [データ構成図](#データ構成図)
- [Hardhat](#hardhat)

# 何を目指すのか？
## 2次創作活動への壁を減らす
- ガイドラインをオープンな場所に設置できる。
- 1次創作元への利用申請フォームを設置できる。
- 申請書を自動・公平・オープンに管理できる。
## ファンが2次創作を安心して好きになれるようする
- 利用者は電子署名をして、ガイドラインに沿って作成したことを証明できる。
- ファンは2次創作者が申請書を提出しているかを簡単に確認できる。
- ファンは申請内容の正当性を読み取ることができる。

# 解決されなくても良しとする問題
- 偽物の申請フォーム・作品が出てくる。
- 利用できる範囲をカテゴライズして管理する。
- 利用範囲によって、使用料を変える。


# データ構成図
```mermaid
classDiagram
    class ArtistContract{
        artistName: string;
        description: string;
        (versionId => Guidline) guidelines;
        (artworkId => Artwork) works;
        createAgreement(): CreativeAgreement;
        mintApplication(): SecondCreativeRequest;
        verifySignature(): boolean;
        tokenURI();
    }

    class WorkContract{
        tokenURI();
    }

    class Artwork{
        // Struct
        fundWallet;
        contractAddress?;
        tokenId?;
        title;
        authors: string[];
        createdAt;
        mediaURL;
        mediaDigest;
        minValue;
        maxValue;
        maxDate; // 1year?
    }

    class Guidline{
        // Struct
        url;
        digest;
        updatedAt;
    }

    class CreativeAgreement{
        // 署名する申請情報。保存しないで使う度に再構成する。
        // 保存はしないのでデータ量は気にしないで良い。
        applicationAddress;
        artworkId; // 作品参照のため
        signerName;
        signerAddress;
        purpose;
        location;
        startDate;
        endDate;
        value;
        guildLineVerId; // URLとdigestを取得するため
        guidlineContent; // 文章に署名したい 
    }

    class SecondCreativeRequest{
        // SBT
        // 発行するメタデータ
        // 他のユーザーが検証に必要なデータ
        // データは少ないほど良い
        name; // NFT名
        discription; // 許諾について説明
        image; // 適当
        applicationAddress;
        applicationId;
        artworkId;
        signerName;
        signerAddress;
        purpose;
        location;
        startDate;
        endDate;
        value;
        guildLineVerId
        signature;
    }

    ArtistContract "1" --> "n" SecondCreativeRequest
    ArtistContract "1" --> "n" Guidline
    ArtistContract "1" --> "n" Artwork
    Artwork "1" --> "1" WorkContract
```

# Hardhat
- ローカルネット起動
    - npx hardhat node
- ローカルでスクリプト実行
    -  npx hardhat run --network localhost scripts/local/foo.ts
- テストネットデプロイ
  - `hardhat.config.ts`にネットワーク情報を入れる。
  - npx hardhat run --network goerli scripts/deploy.ts
- Verify(etherscan)
  - npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS ARGUMENTS_OF_CONSTRUCROR