// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../libraries/LibDiamond.sol";

contract ERC721Facet {
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address _owner) external view returns (uint256) {
        require(
            _owner != address(0),
            "ERC721: balance query for the zero address"
        );
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.balances[_owner];
    }

    function mint(address _to) external returns (uint256) {
        require(_to != address(0), "ERC721: cannot mint to the zero address");
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
         // Increment total supply and use it as the new tokenId
        uint256 tokenId = ds.totalSupply;
        ds.totalSupply += 1;

        // Update balances and ownership
        ds.balances[_to] += 1;
        ds.owners[tokenId] = _to;

        // Emit Transfer event from address(0) to _to
        emit Transfer(address(0), _to, tokenId);

        return tokenId;
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        address owner = ds.owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(
            from == ds.owners[tokenId],
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");
        require(
            msg.sender == from ||
                msg.sender == ds.tokenApprovals[tokenId] ||
                ds.operatorApprovals[from][msg.sender],
            "ERC721: caller is not owner nor approved"
        );

        // Clear approval
        ds.tokenApprovals[tokenId] = address(0);

        // Update balances
        ds.balances[from] -= 1;
        ds.balances[to] += 1;

        // Update ownership
        ds.owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        address owner = ds.owners[tokenId];
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || ds.operatorApprovals[owner][msg.sender],
            "ERC721: approve caller is not owner nor approved for all"
        );

        ds.tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(
            ds.owners[tokenId] != address(0),
            "ERC721: approved query for nonexistent token"
        );
        return ds.tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(operator != msg.sender, "ERC721: approve to caller");
        ds.operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.operatorApprovals[owner][operator];
    }
}
