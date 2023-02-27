// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// スマコン上の処理で必要な申請書データを記録する形
struct Application {

    // 使用するWork発行元のコントラクトアドレス
    address workAddr;
    // 使用するWorkのトークン番号
    uint workId;
    // 著作者のウォレットアドレス
    address leadAuthorAddr;
    // この申請書に署名する公開鍵(申請者のウォレットアドレス)
    address applicant;

    // 使用する期間
    uint startDate;
    uint endDate;
    // 申請を引き下げる日時
    uint cancellationDate;
    
    // 申請日
    uint createdDate;
    // 支払う料金
    uint licenseFees;

    // 契約内容をフロントで纏める
    string applicationJson;
    // applicationJsonを電子署名したもの
    bytes32 fingerprint;

}