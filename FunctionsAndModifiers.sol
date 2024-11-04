// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, Ownable {
    uint256 private _tokenIdCounter;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event TokenMinted(address indexed to, uint256 indexed tokenId);

    constructor() ERC721("MyToken", "MTK") {
        _tokenIdCounter = 0;
    }

    function mintNFT(address to) public onlyOwner {
        require(
            to != address(0),
            "Error: Invalid address. Cannot mint to the zero address."
        );
        uint256 tokenId = _tokenIdCounter;
        _safeMint(to, tokenId);
        _tokenIdCounter += 1;
        emit TokenMinted(to, tokenId);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        require(
            newOwner != address(0),
            "Error: New owner is the zero address."
        );
        emit OwnershipTransferred(owner(), newOwner);
        _transferOwnership(newOwner);
    }

    function getOwner() public view returns (address) {
        return owner();
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _tokenIdCounter > tokenId;
    }
}
