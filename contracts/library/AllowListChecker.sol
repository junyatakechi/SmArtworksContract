// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

// ALを扱うための機能
library AllowListChecker{

    // アローリストの確認
    function isALAccount(address account, uint allowedAmount, bytes32[] calldata proofData, bytes32 root) internal pure returns(bool){
        //
        return verifyWithAddressAmount(account, allowedAmount, proofData, root);
    }

    // ALで設定された初期の可能数のみの取得。
    // [!] 現在の可能数は把握しない。
    function getALMintableAmount(address account, uint allowedAmount, bytes32[] calldata proofData, bytes32 root) internal pure returns(uint){
        // 
        bool isAL = isALAccount( account,  allowedAmount, proofData, root);
        if(isAL){
            return allowedAmount;
        }else{
            // ALではない場合
            return 0;
        }
    }

    // マークルプルーフ
    function verifyWithAddressAmount(
        address account,  uint allowedAmount, bytes32[] calldata proofData, bytes32 root
    ) internal pure returns (bool){
        bytes32 leaf = keccak256(abi.encodePacked(account , allowedAmount));
        return MerkleProof.verify(proofData, root, leaf);
    }


}