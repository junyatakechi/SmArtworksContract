// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

//
interface IBrightLicensable{
    // ライセンスが発行された通知
    event ApprovedApplication(uint applicationId, uint licenseId, address approver);

    // 申請を承認する。
    function approveApplication(uint[] memory applicationIds) external;

    // 承認する権利を持っているかどうか。ライセンス内のapproverを検証する。
    function isApprovers(address account) view external returns(bool);
    
    // ライセンスに載せる著作者名。
    function getLeadAuthorName() view external returns(string memory);

    // ライセンスに載せる著作者のウォレットアドレス
    function getLeadAuthorAddr() view external returns(address);

    // tokenId毎に紐づけれた作品のタイトル
    function getWorkTitle(uint workId) view external returns(string memory);

}