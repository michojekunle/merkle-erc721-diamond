// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;
    mapping(address => bool) public hasClaimed;

    function setMerkleRoot(bytes32 _merkleRoot) external {
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata merkleProof) external {
        require(!hasClaimed[msg.sender], "Already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(merkleProof, merkleRoot, leaf), "Invalid proof");
        
        hasClaimed[msg.sender] = true;
        // Mint NFT to claimer
        ERC721Facet(address(this)).mint(msg.sender);
    }
}
