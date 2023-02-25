// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//
contract BrightLicensableWorkNFT is ERC721{
    //////////////////////////////////////////////////////
    // ロール ////////////////////////////////////////////
    // 著作者
    // TODO: 収益分配のための割合の数値を持つ。
    address[] private _authors;
    // 許諾者 => licenseId
    mapping(address => uint) private _consenterMap;
    // 申請者 => licenseId
    mapping(address => uint) private _applicantMap;
    //////////////////////////////////////////////////////









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