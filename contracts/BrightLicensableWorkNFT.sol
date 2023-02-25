// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IBrightLicensable.sol";
import "./struct/Application.sol";
import "./struct/License.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./library/Convert.sol";

//
contract BrightLicensableWorkNFT is ERC721, IBrightLicensable{
    ///////////////////////////////////////////////////////
    // 著作者情報 /////////////////////////////////////////
    string  private _leadAuthorName = "Takechy";
    address private _leadAuthorAddr = 0x39C2403acAb4D7719F0418d3b64e559D300758d0;
    mapping(uint => string) private _workTitleMap;
    
    ///////////////////////////////////////////////////////
    // トークン   /////////////////////////////////////////
    // applicationId => 申請情報
    mapping(uint => Application) private _applicationMap;
    // licenseId 　　=> 申請情報
    mapping(uint => License) private _licenseMap;
    string[] private _licenseKeyName = [
        "fingerprint", "licenseAddr", "licenseId", "applicationAddr", "applicationId", "applicationFingerprint",
        "approver", "approverName", "approverInfo", "approverDate"
    ];

    //////////////////////////////////////////////////////
    // ロール ////////////////////////////////////////////
    // 著作者
    // TODO: 収益分配のための割合の数値を持つ。
    address[] private _authors;
    // 承認者
    mapping(address => bool) private _approversMap;
    // 申請者 => licenseId
    mapping(address => uint) private _applicantMap;
    // 許諾者 => licenseId
    mapping(address => uint) private _licensorMap;
    //////////////////////////////////////////////////////

    // ライセンスに載せる著作者名。
    function getLeadAuthorName() view external returns(string memory){
        return _leadAuthorName;
    }

    // ライセンスに載せる著作者のウォレットアドレス
    function getLeadAuthorAddr() view external returns(address){
        return _leadAuthorAddr;
    }

    // 作品のタイトル。
    function getWorkTitle(uint workId) view external returns(string memory){
        return _workTitleMap[workId];
    }

    // 承認する権利を持っているかどうか。
    function isApprovers(address account) view external returns(bool){
        return _approversMap[account];
    }

    // TODO: LicenseをカスタムMapでライブり化
    // https://solidity-by-example.org/app/iterable-mapping/
    function showLicense(uint licenseId) view public returns(string memory){
        License storage license = _licenseMap[licenseId];
        string memory fingerprint = Convert.bytes32ToHexString(abi.encodePacked(license.fingerprint));
        string memory applicationFingerprint = Convert.bytes32ToHexString(abi.encodePacked(license.applicationFingerprint));
        string memory data = string(
            abi.encodePacked(
                '{',
                    '"fingerprint":',            '"',  fingerprint,                                          '"', ',',
                    '"licenseAddr":',            '"',  Strings.toHexString(license.licenseAddr),             '"', ',',
                    '"licenseId":',              '"',  Strings.toString(license.licenseId),                  '"', ',',
                    '"applicationAddr":',        '"',  Strings.toHexString(license.applicationAddr),         '"', ',',
                    '"applicationId":',          '"',  Strings.toString(license.applicationId),              '"', ',',
                    '"applicationFingerprint":', '"',  applicationFingerprint,                               '"', ',',
                    '"approver":',               '"',  Strings.toHexString(license.approver),                '"', ',',
                    '"approverName":',           '"',  license.approverName,                                 '"', ',',
                    '"approverInfo":',           '"',  license.approverInfo,                                 '"', ',',
                    '"approverDate":',           '"',  license.approverDate,                                 '"',
                '}'   
            )
        );
        return data;
    }

    // DEBUG: 仮置き
    // ライセンスの作成。
    function _createLicense(uint licenseId) internal{
        // ライセンス構造体
        _licenseMap[licenseId] = License({
            fingerprint: 0x493c228601905ea40eec37ae8423c901976d08e0ea1f9fa6fdc0924ea7633f58,
            licenseAddr: 0x39C2403acAb4D7719F0418d3b64e559D300758d0,
            licenseId: licenseId,
            applicationAddr: 0x39C2403acAb4D7719F0418d3b64e559D300758d0,
            applicationId: licenseId + 1,
            applicationFingerprint: 0x563c228601905ea40eec37ae8423c901976d08e0ea1f9fa6fdc0924ea7633f58,
            approver: 0x39C2403acAb4D7719F0418d3b64e559D300758d0,
            approverName: "takechy",
            approverInfo: "takechy@gmail.com",
            approverDate: "2023-02-25T18:00:00"
        });
    }

    //
    string private _ipfs_base = "";

    //
    constructor() ERC721("BLW", "BLW") {
        // DEBUG: 承認者としてアドレスを登録しておく。
        _approversMap[0x39C2403acAb4D7719F0418d3b64e559D300758d0] = true;
        _createLicense(1);
    }

    //
    function safeMint(address to, uint256 tokenId) external{
        super._safeMint(to, tokenId);
    }

    //
    function _baseURI() internal view override returns (string memory) {
        return _ipfs_base;
    }

}