// merkleTree.ts
import { keccak256 } from "ethers";
import { MerkleTree } from "merkletreejs";
import * as fs from "fs";

// List of addresses for which to generate Merkle tree and proofs
const addresses = [
    "0x1231231231231231231231231231231231231231",
    "0x4564564564564564564564564564564564564564",
    "0x7897897897897897897897897897897897897897",
    "0xabcdefabcdefabcdefabcdefabcdefabcdefabcd",
    "0xfedcbafedcbafedcbafedcbafedcbafedcbafedc"
];

// Generate leaves by hashing the addresses
const leaves = addresses.map(addr => keccak256(addr));

// Create the Merkle tree
const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Get the Merkle root
const root = tree.getHexRoot();

// Generate proofs for each address
const proofs = addresses.map((addr, index) => {
    const leaf = leaves[index];
    const proof = tree.getHexProof(leaf);
    return {
        address: addr,
        proof: proof
    };
});

// Save the Merkle root and proofs to a JSON file
const merkleData = {
    merkleRoot: root,
    proofs: proofs
};

fs.writeFileSync("merkleData.json", JSON.stringify(merkleData, null, 2));

console.log("Merkle Root:", root);
console.log("Proofs have been saved to merkleData.json");
