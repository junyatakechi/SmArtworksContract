// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct Artwork {
    string title;
    string[] authors;
    uint256 createdAt;
    uint256 deactivatedAt;
    string mediaURL;
    string mediaDigest;
    uint256 minValue;
    uint256 maxValue;
    uint256 maxDate;
}
