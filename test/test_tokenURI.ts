import { ethers } from "hardhat";
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");

describe("test_tokenURI.ts", function () {

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("MinimalERC721");
        const [deployer, user1, user2] = await ethers.getSigners();
    
        const contract = await fact.deploy(
            "ERC721_TEST", 
            "ERCT",
            "ipfs://QmRhg78X5sL127UV8pqbd8axJo2mnRhf2hYeFLbngvNtPA/"
          );
    
        await contract.deployed();
    
        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, user1, user2 };
    }

    it('ミントされてないtokenはURIを取得できないべきだ。', async function(){
        this.timeout(40000);
        const { contract, deployer, alice } = await loadFixture(deployTokenFixture);
        try{
            await contract.tokenURI(1);
            assert.fail("例外をキャッチできませんでした。");
        }catch(e: any){
            expect(e.message).to.equal(`call revert exception; VM Exception while processing transaction: reverted with reason string "ERC721: invalid token ID" [ See: https://links.ethers.org/v5-errors-CALL_EXCEPTION ] (method="tokenURI(uint256)", data="0x08c379a0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000184552433732313a20696e76616c696420746f6b656e2049440000000000000000", errorArgs=["ERC721: invalid token ID"], errorName="Error", errorSignature="Error(string)", reason="ERC721: invalid token ID", code=CALL_EXCEPTION, version=abi/5.7.0)`);
        }
    });

});