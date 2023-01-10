import { ethers } from "ethers"; 
import { MerkleTree} from "merkletreejs";
import { keccak256 } from "ethers/lib/utils";

// マークルツリーのオブジェクト作成
export const createMerkleTreeRoot = function(_whitelist: any, _types: string[]): MerkleTree{
    // {key, value}を配列に変換。ここでは2次元配列になる。
    const list_array: any[] = Object.entries(_whitelist);

    // hashの配列化
    const keccak_list = list_array.map(
    info =>
        ethers.utils
        .solidityKeccak256(_types, [info[0], info[1]])
        .slice(2) // 0xをカット。
    );

    // @param leaves — Array of hashed leaves. Each leaf must be a Buffer.
    const merkletree = new MerkleTree(keccak_list, keccak256, { sortPairs: true });

    // View側でroot.getHexRoot();でhashを得る。
    return merkletree;
}

// プルーフ
export const createMerkleTreeProof = function(_whitelist: any, _types: string[], _value: any[], _merkleTree: MerkleTree, _account: string){
    if(!_whitelist[_account]){
        console.error("WARNING: You have no WL");
        return [];
    }else{
        //
        const hash_token = ethers.utils.solidityKeccak256(_types, _value).slice(2); // => 0xカット
        // console.log(hash_token);
        //
        const address_proof = _merkleTree.getHexProof(hash_token);
        return address_proof;
    }

}