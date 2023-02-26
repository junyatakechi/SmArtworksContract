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
    // licenseId 　　=> 申請情報
    mapping(uint => License) private _licenseMap;
    string[] private _licenseKeyName = [
        "fingerprint", "licenseAddr", "licenseId", "applicationAddr", "applicationId", "applicationFingerprint",
        "approver", "approverName", "approverInfo", "approverDate"
    ];
    //
    address public _applicationAddr = 0xa467AB9447AfA5Db0c70325348D810d2058DDe18;
    address public _licenseAddr =     0xDCbEd9cF88384A7b2Fa8ab5D02E35FAFE523baE1;
    uint licenseIdCount = 1;


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
                    '"approverDate":',           '"',  Strings.toString(license.approverDate),               '"',
                '}'   
            )
        );
        return data;
    }

    // 申請を承認する。
    // Data引数
    function approveApplication(uint[] memory applicationIds) external{
        address approver = _msgSender();
        require(_approversMap[approver], "Invaild Approver");
        // TODO: 申請コントラクトのインスタンス

        // ライセンスの付与
        for(uint i=0; i<applicationIds.length; i++){
            _createLicense(
                applicationIds[i],
                licenseIdCount,
                approver,
                "takechy",
                "takechy@gmail.com"
            );
            emit ApprovedApplication(applicationIds[i], licenseIdCount, approver);
            licenseIdCount++;   
        }

    }

    // ライセンスの作成。
    // TODO: burn機能
    function _createLicense(
        uint applicationId,
        uint licenseId,
        address approver,
        string memory approverName,
        string memory approverInfo
    ) internal{
        // ライセンス構造体を保持
        _licenseMap[licenseId] = License({
            fingerprint: 0x493c228601905ea40eec37ae8423c901976d08e0ea1f9fa6fdc0924ea7633f58, // TODO: いつ生成する? 文章に対して？
            licenseAddr: _licenseAddr,
            licenseId: licenseId,
            applicationAddr: _applicationAddr,
            applicationId: applicationId,
            applicationFingerprint: 0x563c228601905ea40eec37ae8423c901976d08e0ea1f9fa6fdc0924ea7633f58,
            approver: approver,
            approverName: approverName,
            approverInfo: approverInfo,
            approverDate: block.timestamp
        });
    }

    // 承認者を追加
    function setApprover(address account, bool state) public{
        _approversMap[account] = state;
    }

    //
    string private _ipfs_base = "";

    //
    constructor() ERC721("BLW", "BLW") {

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