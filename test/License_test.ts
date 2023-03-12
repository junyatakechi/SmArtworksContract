import { ethers } from "hardhat";
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");


describe("License_test.ts", function () {

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("BrightLicensableWorkNFT");
        const [deployer, alice, bob] = await ethers.getSigners();
        const contract = await fact.deploy();
        await contract.deployed();
        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, alice, bob };
    }

    it("ライセンスの発行の発行は承認者ではないと出来ないべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice } = await loadFixture(deployTokenFixture);
        // ライセンスの発行。
        try{
            await contract.approveApplication([1, 2, 3]);
            expect.fail("想定のエラーが発生しませんでした。");
        }catch(e: any){
            expect(e.message).to.equal("VM Exception while processing transaction: reverted with reason string 'Invaild Approver'");
        }
    })

    it('ライセンス情報に載っている承認者が作品のコントラクトの承認者として資格が証明できるべきだ。', async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice } = await loadFixture(deployTokenFixture);
        // 承認者を追加
        await contract.setApprover(deployer.address, true);

        // ライセンスの発行。
        await contract.approveApplication([1, 2, 3]);

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