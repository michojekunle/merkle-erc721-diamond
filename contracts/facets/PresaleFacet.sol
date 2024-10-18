// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";
import "./ERC721Facet.sol";

contract PresaleFacet {
    uint256 public constant RATE = 30; // 1 ETH = 30 NFTs
    uint256 public constant MIN_PURCHASE = 0.01 ether;

    event TokensPurchased(address indexed buyer, uint256 amount);

    function setPresaleActive(bool _start) external {
        LibDiamond.enforceIsContractOwner();
        LibDiamond.diamondStorage().presaleStarted = _start;
    }

    function buyTokens() external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.presaleStarted, "Presale has not started");
        require(msg.value >= MIN_PURCHASE, "Minimum purchase is 0.01 ETH");
        uint256 numNFTs = (msg.value * RATE) / 1 ether;

        require(numNFTs > 0, "Insufficient ETH to buy NFTs");

        for (uint256 i = 0; i < numNFTs; i++) {
            ERC721Facet(address(this)).mint(msg.sender);
        }

        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function withdrawFunds() external {
        LibDiamond.enforceIsContractOwner();
        payable(LibDiamond.contractOwner()).transfer(address(this).balance);
    }
}