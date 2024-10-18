// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ERC721Facet is ERC721Enumerable {
    string private _baseTokenURI;
    uint256 private _currentTokenId;

    constructor() ERC721("DiamondNFT", "DIA") {}

    function mint(address to) external {
        _currentTokenId++;
        _mint(to, _currentTokenId);
    }

    function setBaseURI(string memory baseURI) external {
        _baseTokenURI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
