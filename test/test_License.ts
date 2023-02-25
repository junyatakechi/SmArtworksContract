import { ethers } from "hardhat";
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");

describe("test_License.ts", function () {

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("BrightLicensableWorkNFT");
        const [deployer, alice, bob] = await ethers.getSigners();
        const contract = await fact.deploy();
        await contract.deployed();
        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, alice, bob };
    }

    it('ライセンス情報に載っている承認者が作品のコントラクトの承認者として資格が証明できるべきだ。', async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice } = await loadFixture(deployTokenFixture);
        // 指定のライセンスを取ってくる。
        const license = await contract.showLicense(1);
        const json = JSON.parse(license);
        // ライセンスの中の承認者を抽出。
        const approver = json["approver"];
        // 作品のコントラクトで承認者に資格があるかをチェック。
        const result = await contract.isApprovers(approver);
        //
        expect(result).to.true;
    });

});