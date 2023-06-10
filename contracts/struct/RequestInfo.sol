// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

struct RequestInfo{
    bool isActive;
    string signerName;
    address signerAddress;
    uint artworkId;
    string purpose;
    string location;
    uint startDate;
    uint endDate;
    uint createdDate;
    uint value;
    uint guildLineVerId;
    string signature;
}