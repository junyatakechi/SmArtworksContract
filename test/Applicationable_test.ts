// Applicationable_test.ts
import { ethers } from "hardhat";
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");

describe("Applicationable_test.ts", function () {

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("Applicationable");
        const [deployer, alice, bob] = await ethers.getSigners();
        const contract = await fact.deploy();
        await contract.deployed();
        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, alice, bob };
    }

    it("tokenURIでonchainのjsonが返されるべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice } = await loadFixture(deployTokenFixture);
        //
        const url = await contract.tokenURI(1);
        const data = url.split(",").slice(-1)[0];
        const decoded = Buffer.from(data, "base64").toString();
        let json;
        try{
            json = JSON.parse(decoded);
            const result = json instanceof Object;
            // console.log("json: ", json);
            expect(result).to.be.true;
        }catch(e){
            console.error(e);
            console.log("decoded: ", decoded);
            expect.fail("jsonデータがパース出来ません。");
        }
    })


    it("発行時にダイジェストメッセージは検証されるべきだ", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice } = await loadFixture(deployTokenFixture);
        //
        expect.fail("まだ書いてない");
    })

});