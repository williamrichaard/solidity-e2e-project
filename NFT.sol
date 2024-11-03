// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint256 private _tokenIdCounter;
    address private _owner;

    // Mapping to track token ownership
    mapping(uint256 => address) private _owners;

    // Mapping to track minted tokens
    mapping(uint256 => bool) private _mintedTokens;

    // Event to emit when a token is transferred
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // Event to emit when ownership is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        _owner = initialOwner;
        _tokenIdCounter = 0;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    // Function to transfer ownership
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    // Function to mint a new NFT
    function mintNFT(address to) public onlyOwner {
        require(
            to != address(0),
            "Error: Invalid address. Cannot mint to the zero address."
        );
        uint256 newTokenId = _tokenIdCounter;

        // Assign ownership of the token
        _owners[newTokenId] = to;

        // Mark the token as minted
        _mintedTokens[newTokenId] = true;

        // Emit the transfer event (from address(0) to indicate minting)
        emit Transfer(address(0), to, newTokenId);

        _tokenIdCounter += 1;
    }

    // Function to get the owner of a specific token ID
    function getOwner(uint256 tokenId) public view returns (address) {
        require(
            _mintedTokens[tokenId],
            "Error: The requested token does not exist."
        );
        return _owners[tokenId];
    }

    // Function to check if a token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _mintedTokens[tokenId];
    }

    // Function to get the current owner of the contract
    function owner() public view returns (address) {
        return _owner;
    }
}
