// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./ERC721Facet.sol";
import "../libraries/LibDiamond.sol";

contract MerkleFacet {
    function setMerkleRoot(bytes32 _merkleRoot) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondStorage().merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata merkleProof) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
        require(!ds.hasClaimed[msg.sender], "Address already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(MerkleProof.verify(_merkleProof, ds.merkleRoot, leaf), "Invalid proof");

        ds.hasClaimed[msg.sender] = true;
        
        // Mint NFT to claimer
        ERC721Facet(address(this)).mint(msg.sender);

        emit Claimed(msg.sender, _amount);
    }
}
