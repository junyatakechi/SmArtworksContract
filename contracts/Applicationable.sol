// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./interface/IApplicationable.sol";
import "./struct/Application.sol";

// アーティスト毎に持ち、そのアーティストの作品複数に紐づける。
contract Applicationable is ERC721, IApplicationable{
    // 資金ウォレット
    address private _leadAuthorAddr = 0xe757D1fB6A2841F7Cb9b74Aac491590eb77210b6;
    string private _name = 'TakechyWorkApplication';
    string private _discription = 'This is a application NFT for license.';
    string private _image = 'ar://jY0z7qbJVYFR3kcSDsT-E0sETJtKaR9wJZ40iA7_Khg';

    // tokenIdと署名したJSONデータを保持
    mapping(uint => string) private _applicationJsonMap;
    // applicationId => スマコンで使用する申請情報
    mapping(uint => Application) private _applicationMap;
    // 
    uint applicationIdCount = 1;

    //
    constructor() ERC721("Applicationable", "AP") {
        // DEBUG
        _applicationJsonMap[1] = string(abi.encodePacked(
            '{',
                '"applicationAddr": ',  '"', '0x000000000',               '"', ',',
                '"applicationId": ',    '"', '1',        '"', ',',
                '"name": ',             '"', 'Name of Contract',              '"', ',',
                '"discription": ',      '"', 'I want to use this work.',              '"', ',',
                '"licenseFees": ',      '"', '0.01 ETH',              '"', ',',
                '"workAddr": ',         '"', '0x111111111',              '"', ',',
                '"workId": ',           '"', '1',              '"', ',',
                '"leadAuthorName": ',   '"', 'Junya',              '"', ',',
                '"leadAuthorAddr": ',   '"', '0x2222222222',              '"', ',',
                '"workTitle": ',        '"', 'Awesome Man',              '"', ',',
                '"applicantAddr": ',    '"', '0x3443333333',              '"', ',',
                '"applicantName": ',    '"', 'Hello Token Echonomy',              '"', ',',
                '"applicantContact": ', '"', 'hello@gmail.com',              '"', ',',
                '"useLocation": ',      '"', "test",              '"', ',',
                '"useDetails": ',       '"', Strings.toString(block.timestamp),              '"', ',',
                '"startDate": ',        '"', Strings.toString(block.timestamp),              '"', ',',
                '"endDate": ',          '"', Strings.toString(block.timestamp),              '"', ',',
                '"cancellationDate": ', '"', Strings.toString(block.timestamp),              '"', ',',
                '"createdDate": ',      '"', '0xaba12312baaaacd', '"',
            '}'
        ));
    }

    // TODO: フロントで発行関数を作って実験する。
    // 発行
    function mint(
        address workAddr,
        uint workId,
        uint startDate,
        uint endDate,
        uint cancellationDate,
        string memory applicationJson,  // 契約内容をフロントで纏める
        bytes32 messageDigest           // applicationJsonを電子署名する
    ) external payable{
        address applicant = _msgSender();
        uint licenseFees = msg.value;
        address leadAuthorAddr = _leadAuthorAddr;
        
        // TODO: messageDigestを検証する関数

        // 構造体とtokenIdとの紐づけ。=> スマコン上で使用するために
        _applicationMap[applicationIdCount] = _createApplication(
            workAddr, workId, leadAuthorAddr, applicant, startDate, endDate, cancellationDate, 
            licenseFees, applicationJson, messageDigest
        );

        // 実際に署名したJSONデータとtokenIdとの紐づけ。 => 電子署名と契約内容をNFTにするため。
        _applicationJsonMap[applicationIdCount] = applicationJson;
        
        // 申請者とtokenIdとの紐づけ。=> NFT発行。
        _safeMint(applicant, applicationIdCount);
        
        //
        applicationIdCount++;
    }

    // TODO: burn機能

    // TODO: witdhdraw関数

    // 申請書NFT data:application/json;base64
    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        string storage application = _applicationJsonMap[tokenId];

        // TODO: 期限切れを確認する関数で除外する処理。
        
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": ',         '"', _name,               '"', ',',
                '"discription": ',  '"', _discription,        '"', ',',
                '"image": ',        '"', _image,              '"', ',',
                '"fingerprint": ',  '"', '0xaba12312baaaacd', '"', ',',
                '"application": ',  application, 
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    // TODO: フロントで作らせる
    // application_jsonを整形
    // function _applicationJson(uint tokenId) internal view returns(string memory){
    //     bytes memory data = abi.encodePacked(
    //         '{',
    //             '"applicationAddr": ',  '"', '0x000000000',               '"', ',',
    //             '"applicationId": ',    '"', Strings.toString(tokenId),        '"', ',',
    //             '"name": ',             '"', 'Name of Contract',              '"', ',',
    //             '"discription": ',      '"', 'I want to use this work.',              '"', ',',
    //             '"licenseFees": ',      '"', '0.01 ETH',              '"', ',',
    //             '"workAddr": ',         '"', '0x111111111',              '"', ',',
    //             '"workId": ',           '"', '1',              '"', ',',
    //             '"leadAuthorName": ',   '"', 'Junya',              '"', ',',
    //             '"leadAuthorAddr": ',   '"', '0x2222222222',              '"', ',',
    //             '"workTitle": ',        '"', 'Awesome Man',              '"', ',',
    //             '"applicantAddr": ',    '"', '0x3443333333',              '"', ',',
    //             '"applicantName": ',    '"', 'Hello Token Echonomy',              '"', ',',
    //             '"applicantContact": ', '"', 'hello@gmail.com',              '"', ',',
    //             '"useLocation": ',      '"', "test",              '"', ',',
    //             '"useDetails": ',       '"', _image,              '"', ',',
    //             '"startDate": ',        '"', _image,              '"', ',',
    //             '"endDate": ',          '"', _image,              '"', ',',
    //             '"cancellationDate": ', '"', _image,              '"', ',',
    //             '"createdDate": ',      '"', '0xaba12312baaaacd', '"',
    //         '}'
    //     );

    //     return string(data);
    // }
    
    
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
        bytes32 messageDigest
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
            messageDigest: messageDigest
        });
    }


    // TODO: TESTコードを持ってくる。
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