// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IApplicationable.sol";
import "./struct/Application.sol";

// 
contract Applicationable is ERC721, IApplicationable{
    //
    // applicationId => 申請情報
    mapping(uint => Application) private _applicationMap;
    uint applicationIdCount = 1;

    //
    constructor() ERC721("Applicationable", "AP") {}

    // 発行
    function mint(
        address workAddr,
        uint workId,
        string memory leadAuthorName,
        address leadAuthorAddr,
        string memory workTitle,
        address applicant,
        string memory applicantName,
        string memory contactInfo,
        string memory useLocation,
        string memory purpose,
        uint startDate,
        uint endDate,
        uint cancellationDate,
        uint licenseFees
    ) external{
        _createApplication(
            applicationIdCount,
            workAddr,
            workId,
            leadAuthorName,
            leadAuthorAddr,
            workTitle,
            applicant,
            applicantName,
            contactInfo,
            useLocation,
            purpose,
            startDate,
            endDate,
            cancellationDate,
            licenseFees
        );
        //
        _safeMint(applicant, applicationIdCount);
        applicationIdCount++;
        //
    }

    // TODO: burn機能

    // onchain URL
    
    // ERROR: Stack too deep. => データが多すぎる？プログラム上使わないデータはバイナリにする。
    // 申請内容の作成。
    function _createApplication(
        uint applicationId,
        address workAddr,
        uint workId,
        string memory leadAuthorName,
        address leadAuthorAddr,
        string memory workTitle,
        address applicant,
        string memory applicantName,
        string memory contactInfo,
        string memory useLocation,
        string memory purpose,
        uint startDate,
        uint endDate,
        uint cancellationDate,
        uint licenseFees
    ) internal{
        // ライセンス構造体を保持
        _applicationMap[applicationId] = Application({
            fingerprint: 0x493c228601905ea40eec37ae8423c901976d08e0ea1f9fa6fdc0924ea7633f58, // TODO: いつ生成する? 文章に対して？
            applicationAddr: address(this),
            applicationId: applicationId,
            workAddr: workAddr,
            workId: workId,
            leadAuthorName: leadAuthorName,
            leadAuthorAddr: leadAuthorAddr,
            workTitle: workTitle,
            applicant: applicant,
            applicantName: applicantName,
            contactInfo: contactInfo,
            useLocation: useLocation,
            purpose: purpose,
            startDate: startDate,
            endDate: endDate,
            cancellationDate: cancellationDate,
            createdDate: block.timestamp,
            licenseFees: licenseFees
        });
    }


    // TODO: TESTコード書く
    // 転送不可SBT 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId, /* firstTokenId */
        uint256 batchSize
    ) internal virtual override(ERC721){
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        require(
            from == address(0) || to == address(0),
            "Not allowed to transfer token"
        );
    }

}