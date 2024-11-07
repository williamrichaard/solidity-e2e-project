// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MyToken - A simple ERC-721-like NFT contract
/// @notice This contract mimics the basic functionality of ERC-721 tokens,
/// including minting and ownership management.
contract MyToken {
    string public name = "MyToken";
    string public symbol = "MTK";
    uint256 private _tokenIdCounter;
    address private _owner;

    // Mapping to track ownership of tokens
    mapping(uint256 => address) private _owners;
    // Mapping to track minted tokens
    mapping(uint256 => bool) private _mintedTokens;

    // Event emitted when a token is transferred or minted
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    // Event emitted when ownership of the contract changes
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    // Event emitted when a new token is minted
    event TokenMinted(address indexed to, uint256 indexed tokenId);

    /// @notice Constructor to initialize the contract and set the initial owner
    /// @param initialOwner The address of the initial contract owner
    constructor(address initialOwner) {
        require(initialOwner != address(0), "Invalid initial owner address.");
        _owner = initialOwner;
        _tokenIdCounter = 0;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    // Modifier to ensure only the contract owner can execute certain functions
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    /// @notice Transfer ownership of the contract to a new address
    /// @param newOwner The new owner's address
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /// @notice Mint a new token to a given address
    /// @param to The address to mint the token to
    function mintNFT(address to) public onlyOwner {
        require(to != address(0), "Cannot mint to the zero address");
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
        _tokenIdCounter += 1;
    }

    /// @notice Mint multiple tokens to a given address
    /// @param to The address to mint the tokens to
    /// @param numberOfTokens The number of tokens to mint
    function mintMultiple(address to, uint256 numberOfTokens) public onlyOwner {
        require(to != address(0), "Cannot mint to the zero address");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            uint256 newTokenId = _tokenIdCounter;

            // Ensure the token has not been minted before
            require(
                !_mintedTokens[newTokenId],
                "Token has already been minted"
            );

            // Mint the token
            _owners[newTokenId] = to;
            _mintedTokens[newTokenId] = true;

            // Emit Transfer and TokenMinted events
            emit Transfer(address(0), to, newTokenId);
            emit TokenMinted(to, newTokenId);

            // Increment the token counter for the next mint
            _tokenIdCounter += 1;
        }
    }

    /// @notice Get the owner of a specific token
    /// @param tokenId The ID of the token
    /// @return The address of the owner
    function getOwner(uint256 tokenId) public view returns (address) {
        require(_mintedTokens[tokenId], "Token does not exist");
        return _owners[tokenId];
    }

    /// @notice Check if an address is the owner of a specific token
    /// @param account The address to check
    /// @param tokenId The ID of the token
    /// @return True if the address is the owner, false otherwise
    function isOwnerOf(
        address account,
        uint256 tokenId
    ) public view returns (bool) {
        return _owners[tokenId] == account;
    }

    /// @notice Get the current owner of the contract
    /// @return The address of the current owner
    function owner() public view returns (address) {
        return _owner;
    }
}
