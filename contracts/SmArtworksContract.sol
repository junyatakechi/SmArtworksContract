// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./struct/Artwork.sol";
import "./struct/Guideline.sol";

//
contract SmArtworksContract is Ownable{

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

}