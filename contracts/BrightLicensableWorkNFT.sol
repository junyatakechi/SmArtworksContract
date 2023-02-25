// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IBrightLicensable.sol";

//
contract BrightLicensableWorkNFT is ERC721, IBrightLicensable{
    // ライセンス関係
    string  private _leadAuthorName = "Takechy";
    address private _leadAuthorAddr = 0x39C2403acAb4D7719F0418d3b64e559D300758d0;
    mapping(uint => string) private _workTitleMap;


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

    // 承認する権利を持っているかどうか。
    function isApprovers(address account) view external returns(bool){
        return _approversMap[account];
    }

    // ライセンスに載せる著作者名。
    function getLeadAuthorName() view external returns(string memory){
        return _leadAuthorName;
    }

    // ライセンスに載せる著作者のウォレットアドレス
    function getLeadAuthorAddr() view external returns(address){
        return _leadAuthorAddr;
    }


    // tokenId毎に紐づけれた作品のタイトル
    function getWorkTitle(uint workId) view external returns(string memory){
        return _workTitleMap[workId];
    }




    // address public owner;
    string public ipfs_base;
    //
    constructor(string memory _name, string memory _symbol, string memory _ipfs_base) ERC721(_name, _symbol) {
        ipfs_base = _ipfs_base;
    }

    //
    function safeMint(address to, uint256 tokenId) external{
        super._safeMint(to, tokenId);
    }

    //
    function _baseURI() internal view override returns (string memory) {
        return ipfs_base;
    }
    
}