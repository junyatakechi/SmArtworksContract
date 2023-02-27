// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IApplicationable.sol";
import "./struct/Application.sol";

// アーティスト毎に持ち、そのアーティストの作品複数に紐づける。
contract Applicationable is ERC721, IApplicationable{
    //
    // applicationId => 申請情報
    mapping(uint => Application) private _applicationMap;
    uint applicationIdCount = 1;

    //
    constructor() ERC721("Applicationable", "AP") {}

    // TODO: フロントで発行関数を作って実験する。
    // 発行
    function mint(
        address workAddr,
        uint workId,
        address leadAuthorAddr,
        address applicant,
        uint startDate,
        uint endDate,
        uint cancellationDate,
        uint licenseFees,
        string memory applicationJson,  // 契約内容をフロントで纏める
        bytes32 fingerprint             // applicationJsonを電子署名する
    ) external{

        // tokenIdと構造体の紐づけ。
        _applicationMap[applicationIdCount] = _createApplication(
            workAddr, workId, leadAuthorAddr, applicant, startDate, endDate, cancellationDate, 
            licenseFees, applicationJson, fingerprint
        );
        
        // tokenIdと申請者の紐づけ。
        _safeMint(applicant, applicationIdCount);
        
        //
        applicationIdCount++;
    }

    // TODO: burn機能

    // TODO: 構造体からメタデータ生成を生成する関数。
    // onchain URL 
    
    // ERROR: Stack too deep. => データが多すぎる？プログラム上使わないデータはバイナリにする。
    // 申請内容の作成。
    function _createApplication(
        address workAddr,
        uint workId,
        address leadAuthorAddr,
        address applicant,
        uint startDate,
        uint endDate,
        uint cancellationDate,
        uint licenseFees,
        string memory applicationJson,
        bytes32 fingerprint
    ) internal view returns(Application memory){
        return Application({
            workAddr: workAddr,
            workId: workId,
            leadAuthorAddr: leadAuthorAddr,
            applicant: applicant,
            startDate: startDate,
            endDate: endDate,
            cancellationDate: cancellationDate,
            createdDate: block.timestamp,
            licenseFees: licenseFees,
            applicationJson: applicationJson,
            fingerprint: fingerprint
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