// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// 申請書に対して許諾を承認するライセンスに必要なデータ。
struct license {
    // 許諾書をJSON形式にして、その中に許諾内容に対して署名したhashを含める。
    bytes32 fingerprint;

    ///////////////////////////////////////////////////////////////////////
    // このライセンス発行元のコントラクトアドレス
    address licenseAddr;
    // このライセンスのトークン番号
    uint licenseId;
    
    ///////////////////////////////////////////////////////////////////////
    // 承認する申請書の発行元のコントラクトアドレス
    address applicationAddr;
    // 承認するののトークン番号
    uint applicationId;
    // 申請書の電子署名ハッシュ値
    bytes32 applicationFingerprint;

    ///////////////////////////////////////////////////////////////////////
    // このライセンスに署名する公開鍵(許諾者のウォレットアドレス)
    address consenter;
    // 許諾者の名前
    string consenterName;
    // 許諾者の連絡先(email or phone number, etc...)
    string consenterInfo;
    // 許諾した日時
    string consentDate;

}