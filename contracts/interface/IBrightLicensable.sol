// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

//
interface IBrightLicensable{
    
    // ライセンスに載せる著作者名。
    function getLeadAuthorName() view external returns(string memory);

    // ライセンスに載せる著作者のウォレットアドレス
    function getLeadAuthorAddr() view external returns(address);

}