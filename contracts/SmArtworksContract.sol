// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./struct/Artwork.sol";

//
contract SmArtworksContract {

    uint256 private currentWorkId;
    mapping(uint256 => Artwork) public works;

    function addWork(
        string memory _title, 
        string[] memory _authors,
        string memory _mediaURL,
        string memory _mediaDigest,
        uint256 _minValue,
        uint256 _maxValue,
        uint256 _maxDate
    ) external {
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

    function deactivateWork(uint256 _workId) external {
        require(works[_workId].deactivatedAt == 0, "This Artwork is already inactive.");
        works[_workId].deactivatedAt = block.timestamp;
    }

    function getWork(uint256 _workId) public view returns (Artwork memory) {
        require(works[_workId].deactivatedAt == 0, "This Artwork is inactive.");
        return works[_workId];
    }
    

}