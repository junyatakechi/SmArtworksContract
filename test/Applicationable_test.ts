// Applicationable_test.ts
import { ethers } from "hardhat";
import { Signer } from "ethers"
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");
import { IApplicationJSON } from "../scripts/interface/IApplicationJSON";

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
        const { fact, contract, deployer, alice, bob } = await loadFixture(deployTokenFixture);
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
        // console.log(message);
        // console.log(pubkey);

        // ダイジェスト化
        const messageDigest = await contract.getMessageHash(JSON.stringify(application_json));
        // console.log("messageDigest:", messageDigest.length);

        // string型から32長のバイト列に変換する。
        const messageDigest_arr = ethers.utils.arrayify(messageDigest);
        // console.log("messageDigest_arr:", messageDigest_arr);
        // console.log("messageDigest_arr:", messageDigest_arr.length);

        // [!] 署名 => messageDigestのバイト列に署名する。
        // `\x19Ethereum Signed Message:\n`がprefixdされてからHash化される。
        // 末尾の`n`は署名するメッセージの長さを指定する。
        // 今回はメッセージダイジェスト(32bytes)なので、Verify側も`n=32`を想定する必要がある。
        // `signMessage()`はethereumの署名ロジックをカプセル化している。
        // メッセージダイジェストはstring型だと`n=66`になってしまう。ex) "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
        // メッセージダイジェストをUint8Array(32)の型にすると、`n=32`としてprefixされる。Uint8Array(32) [1, ... , 32]
        const signature = await signer.signMessage(messageDigest_arr);

        //
        const isVerified = await contract.verify(
            pubkey,
            message,
            signature
        );
        console.log("Verify: ", isVerified);

        // // メッセージダイジェスト=> UTF-8 bytes and computes the keccak256.
        // 
        // console.log("messageDigest: ", messageDigest);
        // console.log("messageDigest: ", messageDigest.length);

        // // 署名
        // // https://docs.ethers.org/v6-beta/getting-started/#starting-signing
        // // https://docs.ethers.org/v6-beta/api/providers/#Signer-signMessage
        // const signer = alice as Signer;
        // // prefixd with "\x19Ethereum Signed Message:\n" and the length of the message,
        // let sig = await signer.signMessage(ethers.utils.(messageDigest));
        // console.log("sig: ", sig);
        // console.log("sig: ", sig.length);

        // 確認
        const validated = ethers.utils.verifyMessage(JSON.stringify(application_json), messageDigest);
        expect(validated).to.equal(alice.address);

        // ERROR: messageDigestのデータの長さ。仕様を確認する。
        console.log("length: ", messageDigest.length)
        try{
            await contract.connect(deployer).mint(
                workAddr, workId, startDate, endDate, cancellationDate, JSON.stringify(application_json), messageDigest
            );
            //
            expect.fail("予想したエラーが起こりませんでした。");
        }catch(e: any){
            expect(e.message).to.equal("test");
        }

    })

});