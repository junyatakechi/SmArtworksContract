// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Reference 
// - https://docs.openzeppelin.com/contracts/4.x/api/token/erc721#ERC721
// - https://docs.opensea.io/docs/getting-started
// - https://youtu.be/9PBq9HfBUDY?t=1145


import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//
contract MinimalERC721 is ERC721{
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