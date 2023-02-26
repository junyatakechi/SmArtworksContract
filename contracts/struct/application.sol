// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// TODO: プログラム上使わないデータはJSON形式でバイナリデータとして格納する。=> metadeta
// 使用許諾を得るための申請書に必要なデータ。
struct Application {
    // 申請書をJSON形式にして、その中に申請内容に対して署名したhashを含める。
    bytes32 fingerprint;

    //////////////////////////////////////////////////////////////////////////////////
    // この申請書発行元のコントラクトアドレス
    address applicationAddr;
    // この申請書のトークン番号
    uint applicationId;

    //////////////////////////////////////////////////////////////////////////////////
    // 使用するWork発行元のコントラクトアドレス
    address workAddr;
    // 使用するWorkのトークン番号
    uint workId;
    // 著作者名
    string leadAuthorName;
    // 著作者のウォレットアドレス
    address leadAuthorAddr;
    // 作品のタイトル
    string workTitle;

    /////////////////////////////////////////////////////////////////////////////////
    // この申請書に署名する公開鍵(申請者のウォレットアドレス)
    address applicant;
    // 使用者の名前
    string applicantName;
    // 使用者の連絡先(email or phone number, etc...)
    string contactInfo;
    // 使用する場所(web site or address, etc...)
    string useLocation;
    // 使用目的(DJ, Radio, cover song, etc...)
    string details;
    // 使用する期間
    // スマコン上ではUnixtimeを使用。フロントではISO8601拡張形式(YYYY-MM-DDThh:mm:ss)
    uint startDate;
    uint endDate;
    // 申請を引き下げる日時
    // 誰も承認しなければ自動的に`licenseFees`を返金する。
    uint cancellationDate;
    // 申請日
    uint createdDate;
    // 支払う料金
    uint licenseFees;

}