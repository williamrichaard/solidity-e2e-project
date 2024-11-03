// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MyToken - A simple ERC-721-like NFT contract
/// @notice This contract follows the ERC-721 standard for NFTs, with basic minting and ownership functionality.
/// @dev This contract is not fully ERC-721 compliant but mimics the basic functionality for educational purposes.
contract MyToken {
    // Public variables for the token name and symbol
    string public name = "MyToken";
    string public symbol = "MTK";

    // Counter to keep track of the next token ID to be minted
    uint256 private _tokenIdCounter;

    // Address of the contract owner
    address private _owner;

    // Mapping to track token ownership by token ID
    mapping(uint256 => address) private _owners;

    // Mapping to track whether a token has been minted
    mapping(uint256 => bool) private _mintedTokens;

    // Event to emit when a token is transferred (including minting)
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    // Event to emit when ownership of the contract is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @notice Constructor to initialize the contract with an initial owner
    /// @param initialOwner The address of the initial owner of the contract
    constructor(address initialOwner) {
        require(
            initialOwner != address(0),
            "Error: Invalid initial owner address."
        );
        _owner = initialOwner;
        _tokenIdCounter = 0;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    // Modifier to restrict access to the owner of the contract
    modifier onlyOwner() {
        require(msg.sender == _owner, "Caller is not the owner");
        _;
    }

    /// @notice Function to transfer ownership of the contract
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /// @notice Function to mint a new NFT
    /// @dev Only the owner of the contract can mint new tokens
    /// @param to The address to which the new token will be minted
    function mintNFT(address to) public onlyOwner {
        require(
            to != address(0),
            "Error: Invalid address. Cannot mint to the zero address."
        );
        uint256 newTokenId = _tokenIdCounter;

        // Ensure the token has not been minted before
        require(
            !_mintedTokens[newTokenId],
            "Error: Token has already been minted."
        );

        // Assign ownership of the token to the 'to' address
        _owners[newTokenId] = to;

        // Mark the token as minted
        _mintedTokens[newTokenId] = true;

        // Emit the transfer event (from address(0) to indicate minting)
        emit Transfer(address(0), to, newTokenId);

        // Increment the token ID counter for the next mint
        _tokenIdCounter += 1;
    }

    /// @notice Function to get the owner of a specific token ID
    /// @param tokenId The ID of the token to query
    /// @return The address of the owner of the token
    function getOwner(uint256 tokenId) public view returns (address) {
        require(
            _mintedTokens[tokenId],
            "Error: The requested token does not exist."
        );
        return _owners[tokenId];
    }

    /// @notice Internal function to check if a token exists
    /// @param tokenId The ID of the token to check
    /// @return True if the token exists, false otherwise
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _mintedTokens[tokenId];
    }

    /// @notice Function to get the current owner of the contract
    /// @return The address of the current owner of the contract
    function owner() public view returns (address) {
        return _owner;
    }
}
