// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "./struct/Artwork.sol";
import "./struct/Guideline.sol";

//
contract SmArtworksContract is ERC721, Ownable{

    uint256 private currentWorkId;
    mapping(uint256 => Artwork) public works;
     

    uint256 public currentVersion;
    mapping(uint256 => Guideline) public guidelines;

    function getWork(uint256 _workId) public view returns (Artwork memory) {
        require(works[_workId].deactivatedAt == 0, "This Artwork is inactive.");
        return works[_workId];
    }

    function getCurrentGuideline() public view returns (Guideline memory) {
        require(currentVersion > 0, "No guideline is available.");
        return guidelines[currentVersion];
    }

    function getGuideline(uint256 version) external view returns (Guideline memory) {
        return guidelines[version];
    }

    function createCreativeAgreement(
        uint256 _workId,
        string memory _signerName,
        string memory _purpose,
        string memory _location,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _value,
        uint256 _guildLineVerId,
        string memory _guidlineContent
    ) public view returns (string memory){
        string memory signerAddress = Strings.toHexString(uint256(uint160(msg.sender)));
        return string(abi.encodePacked(
            "{",
            '"applicationAddress":', '"', Strings.toHexString(uint256(uint160(address(this)))), '",',
            '"workId":', Strings.toString(_workId), ',',
            '"signerName":', '"', _signerName, '",',
            '"signerAddress":', '"', signerAddress, '",',
            '"purpose":', '"', _purpose, '",',
            '"location":', '"', _location, '",',
            '"startDate":', Strings.toString(_startDate), ',',
            '"endDate":', Strings.toString(_endDate), ',',
            '"value":', Strings.toString(_value), ',',
            '"guildLineVerId":', '"', Strings.toString(_guildLineVerId), '",',
            '"guidlineContent":', '"', _guidlineContent, '"',
            "}"
        ));
    }

    // metadata for NFT
    function _createSecondCreativeRequest(
        uint256 _workId,
        address _signerAddress,
        string memory _signerName,
        string memory _purpose,
        string memory _location,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _value,
        uint256 _guildLineVerId,
        string memory _signature  // Signature has been added
    ) internal view returns (string memory){
        Artwork memory artwork = getWork(_workId);
        string memory applicationAddress = Strings.toHexString(uint256(uint160(address(this))));
        string memory signerAddress = Strings.toHexString(uint256(uint160(_signerAddress)));
        string memory applicationId = "TODO";  // Update with actual value

        return string(abi.encodePacked(
            "{",
            '"name": "', artwork.title, '",',
            '"discription": "', 'Description Here', '",',
            '"image": "', artwork.mediaURL, '",',
            '"applicationAddress": "', applicationAddress, '",',
            '"applicationId": "', applicationId, '",',
            '"workId":', Strings.toString(_workId), ',',
            '"signerName": "', _signerName, '",',
            '"signerAddress": "', signerAddress, '",',
            '"purpose": "', _purpose, '",',
            '"location": "', _location, '",',
            '"startDate":', Strings.toString(_startDate), ',',
            '"endDate":', Strings.toString(_endDate), ',',
            '"value":', Strings.toString(_value), ',',
            '"guildLineVerId": "', Strings.toString(_guildLineVerId), '",',
            '"signature": "', _signature, '"',
            "}"
        ));
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        // TODO: Update the parameters accordingly
        string memory signerName = "Signer Name Here";
        string memory purpose = "Purpose Here";
        string memory location = "Location Here";
        uint256 startDate = 0;
        uint256 endDate = 0;
        uint256 value = 0;
        uint256 guildLineVerId = 0;
        string memory signature = "Signature Here";

        string memory json = _createSecondCreativeRequest(
            tokenId,
            msg.sender,
            signerName,
            purpose,
            location,
            startDate,
            endDate,
            value,
            guildLineVerId,
            signature
        );

        string memory dataURI = string(abi.encodePacked(
            "data:application/json;base64,", 
            Base64.encode(bytes(json))
        ));

        return dataURI;
    }


    /// For Artist /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function addWork(
        string memory _title, 
        string[] memory _authors,
        string memory _mediaURL,
        string memory _mediaDigest,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _maxDate
    ) external onlyOwner{
        currentWorkId++;
        Artwork memory newWork = Artwork({
            title: _title,
            authors: _authors,
            createdAt: block.timestamp,
            deactivatedAt: 0,
            mediaURL: _mediaURL,
            mediaDigest: _mediaDigest,
            minValue: _minValue,
            maxValue: _maxValue,
            maxDate: _maxDate
        });
        works[currentWorkId] = newWork;
    }

    function deactivateWork(uint256 _workId) external onlyOwner {
        require(works[_workId].deactivatedAt == 0, "This Artwork is already inactive.");
        works[_workId].deactivatedAt = block.timestamp;
    }

    function addGuideline(string memory _url, string memory _digest) external onlyOwner {
        currentVersion++;
        guidelines[currentVersion] = Guideline(_url, _digest, block.timestamp);
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////////////////

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