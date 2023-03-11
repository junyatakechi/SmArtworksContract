// Applicationable_test.ts
import { ethers } from "hardhat";
import { Signer } from "ethers"
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect, assert } = require("chai");

describe("VerifySignature_test.ts", function () {

    // 共通
    async function deployTokenFixture() {
        const fact = await ethers.getContractFactory("Applicationable");
        const [deployer, alice, bob] = await ethers.getSigners();
        const contract = await fact.deploy();
        await contract.deployed();
        // Fixtures can return anything you consider useful for your tests
        return { fact, contract, deployer, alice, bob };
    }

    it("フロントでした署名をスマコンで検証できるべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice, bob } = await loadFixture(deployTokenFixture);
        //
        const signer = alice as Signer;
        const message = JSON.stringify("Hello World");
        const pubkey = await signer.getAddress();
        // console.log(message);
        // console.log(pubkey);

        // ダイジェスト化
        const messageDigest = await contract.getMessageHash(message);
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
        expect(isVerified).to.be.true;
    })

    it("署名者ではなかった場合を検出できるべきだ。", async function(){
        this.timeout(40000);
        const { fact, contract, deployer, alice, bob } = await loadFixture(deployTokenFixture);
        //
        const signer = alice as Signer;
        const message = JSON.stringify("Hello World");
        const pubkey = await signer.getAddress();
        // console.log(message);
        // console.log(pubkey);

        // ダイジェスト化
        const messageDigest = await contract.getMessageHash(message);
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
            bob.address, // [!] 検証するアカウント
            message,
            signature
        );
        expect(isVerified).to.be.false;
    })

});