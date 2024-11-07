// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title ERC721Token - A basic ERC-721-like NFT contract
/// @notice This contract allows minting, transferring, and ownership management of NFTs.
contract ERC721Token {
    string public name = "ERC721Token";
    string public symbol = "E721";
    uint256 private _tokenIdCounter;
    uint256 public maxSupply = 10000; // Maximum supply for the NFTs
    address private _owner;

    // Mapping to track ownership of tokens
    mapping(uint256 => address) private _owners;
    // Mapping to track minted tokens
    mapping(uint256 => bool) private _mintedTokens;
    // Authorized minters (initially the owner)
    mapping(address => bool) private _authorizedMinters;

    // Events
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event TokenMinted(address indexed to, uint256 indexed tokenId);
    event MinterAuthorized(address indexed minter);
    event MinterRevoked(address indexed minter);

    /// @notice Constructor to initialize the contract and set the initial owner
    /// @param initialOwner The address of the initial contract owner
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Invalid initial owner address.");
        _owner = initialOwner;
        _tokenIdCounter = 0;
        _authorizedMinters[initialOwner] = true; // Owner is an authorized minter
        emit OwnershipTransferred(address(0), initialOwner);
    }

    // Modifier to ensure only the contract owner can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    // Modifier to ensure the caller is an authorized minter
    modifier onlyAuthorized() {
        require(
            _authorizedMinters[msg.sender],
            "Caller is not an authorized minter"
        );
        _;
    }

    /// @notice Transfer ownership of the contract to a new address
    /// @param newOwner The new owner's address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /// @notice Add a new address to the list of authorized minters
    /// @param minter The address to authorize as a minter
    function authorizeMinter(address minter) public onlyOwner {
        require(minter != address(0), "Cannot authorize zero address");
        require(
            !_authorizedMinters[minter],
            "Address is already an authorized minter"
        );
        _authorizedMinters[minter] = true;
        emit MinterAuthorized(minter);
    }

    /// @notice Revoke a minter's authorization to mint tokens
    /// @param minter The address to revoke
    function revokeMinter(address minter) public onlyOwner {
        require(
            _authorizedMinters[minter],
            "Address is not an authorized minter"
        );
        _authorizedMinters[minter] = false;
        emit MinterRevoked(minter);
    }

    /// @notice Mint a new token to a given address
    /// @param to The address to mint the token to
    function mintNFT(address to) public onlyAuthorized {
        require(to != address(0), "Cannot mint to the zero address");
        require(_tokenIdCounter < maxSupply, "Max supply reached");

        uint256 newTokenId = _tokenIdCounter;

        // Ensure the token has not been minted yet
        require(!_mintedTokens[newTokenId], "Token has already been minted");

        // Mint the token
        _owners[newTokenId] = to;
        _mintedTokens[newTokenId] = true;

        // Emit Transfer and TokenMinted events
        emit Transfer(address(0), to, newTokenId);
        emit TokenMinted(to, newTokenId);

        // Increment the token counter for future mints
        _tokenIdCounter++;
    }

    /// @notice Get the owner of a specific token
    /// @param tokenId The ID of the token
    /// @return The address of the owner
    function getOwner(uint256 tokenId) public view returns (address) {
        require(_mintedTokens[tokenId], "Token does not exist");
        return _owners[tokenId];
    }

    /// @notice Get the current owner of the contract
    /// @return The address of the current owner
    function owner() public view returns (address) {
        return _owner;
    }
}
