// Applicationable_test.ts
import { ethers } from "hardhat";
import { Signer } from "ethers"
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");
import { IApplicationJSON } from "../formats/IApplicationJSON";

describe("Applicationable_test.ts", function () {

    // TODO: 発行したメタデータから、検証してVerify出来るべきだ。

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("Applicationable");
        const [deployer, alice, bob] = await ethers.getSigners();
        const contract = await fact.deploy();
        await contract.deployed();

        //
        //
        const workAddr = "0x35fe70703731cEaF4DA675c01c60db2BD24157e9";
        const workId = 5;
        const applicantAddr = alice.address;
        const licenseFees = Number(ethers.utils.parseEther("0.01"));
        const startDate = Date.parse("2023-01-01T00:00:00Z") / 1000;
        const endDate =   Date.parse("2024-01-01T00:00:00Z") / 1000;
        const cancellationDate = Date.parse("2023-03-31T00:00:00Z") / 1000;
        const createdDate = Math.floor(Date.now() / 1000);
        //
        const application_json: IApplicationJSON = {
            applicationAddr: contract.address,
            name: "音楽利用許諾申請",
            discription: "使用許諾をお願いしたく思います。",
            licenseFees: licenseFees,
            workAddr: workAddr,
            workId: workId,
            leadAuthorName: "江戸レナ",
            leadAuthorAddr: "0x4Af6158D35Fb5c14D7bf2aF66C7958114b882f4A",
            workTitle: "KYOSO",
            applicantAddr: applicantAddr,
            applicantName: "Takechy",
            applicantContact: "takechi48j@gmail.com",
            useLocation: "https://www.youtube.com/watch?v=RheVEBwAdB4",
            useDetails: "プロモーションビデオのBGMとして",
            startDate: startDate,
            endDate: endDate,
            cancellationDate: cancellationDate,
            createdDate: createdDate
        }
        // console.log(application_json);

        //
        const signer = alice as Signer;
        const message = JSON.stringify(application_json);
        const pubkey = await signer.getAddress();



        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, alice, bob, signer, message, pubkey, workAddr, workId, startDate, endDate, cancellationDate};
    }

    it("発行する場合は署名したダイジェストメッセージを添付するべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice, bob, signer, message, pubkey, workAddr, workId, startDate, endDate, cancellationDate } = await loadFixture(deployTokenFixture);
     

        // ダイジェスト化
        const messageDigest = await contract.getMessageHash(message);
        // string型から32長のバイト列に変換する。
        const messageDigest_arr = ethers.utils.arrayify(messageDigest);

        // 署名: `\x19Ethereum Signed Message:\n`がprefixdされてからHash化される。
        // 末尾の`n`は署名するメッセージの長さを指定する。
        const signature = await signer.signMessage(messageDigest_arr);
        // console.log(signature);

        // 発行。
        await contract.connect(alice).mint(
            workAddr,
            workId,
            startDate,
            endDate,
            cancellationDate,
            message,
            signature
        );

        const balance = await contract.balanceOf(alice.address);
        expect(Number(balance)).to.equal(1);

        const tokenURI = await contract.tokenURI(1);
        // console.log(tokenURI);

    })

    it("tokenURIでonchainのjsonが返されるべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice, bob, signer, message, pubkey, workAddr, workId, startDate, endDate, cancellationDate } = await loadFixture(deployTokenFixture);
        
        // 発行
        const messageDigest = await contract.getMessageHash(message);
        const messageDigest_arr = ethers.utils.arrayify(messageDigest);
        const signature = await signer.signMessage(messageDigest_arr);
        await contract.connect(alice).mint(
            workAddr,
            workId,
            startDate,
            endDate,
            cancellationDate,
            message,
            signature
        );
        
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
});