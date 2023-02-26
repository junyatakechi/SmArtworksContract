// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./interface/IApplicationable.sol";
import "./struct/Application.sol";
import "./struct/License.sol";

// 
contract Applicationable is ERC721, IApplicationable{

    //
    string private _ipfs_base = "ipfs://QmTivXWqnAk8wM629Tzv1TdUtUAg6DuGBkhedN8BX1Ef9a/";

    //
    constructor() ERC721("Applicationable", "AP") {}


    //
    function _baseURI() internal view override returns (string memory) {
        return _ipfs_base;
    }

    // 発行
    function mint() external{
        // _safeMint(to, tokenId);
    }

    // TODO: burn機能


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