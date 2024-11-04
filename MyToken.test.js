const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
  let myTokenInstance;
  const owner = accounts[0]; // Contract owner
  const nonOwner = accounts[1]; // Non-owner account
  const anotherAccount = accounts[2]; // Another account
  const zeroAddress = "0x0000000000000000000000000000000000000000"; // Zero address

  // Before each test, deploy a new instance of the contract
  beforeEach(async () => {
    myTokenInstance = await MyToken.new(owner, { from: owner });
  });

  // Test minting a new token to a valid address
  it("should mint a new token to a valid address", async () => {
    const receipt = await myTokenInstance.mintNFT(nonOwner, { from: owner });
    const tokenId = 0;

    // Check that the Transfer event was emitted
    assert.equal(receipt.logs[0].event, "Transfer", "Transfer event should be emitted");
    assert.equal(receipt.logs[0].args.to, nonOwner, "Token should be minted to the correct address");
    assert.equal(receipt.logs[0].args.tokenId.toNumber(), tokenId, "Token ID should be correct");

    // Check that the token exists and is owned by the correct address
    const ownerOfToken = await myTokenInstance.getOwner(tokenId);
    assert.equal(ownerOfToken, nonOwner, "The owner of the token should be the correct address");
  });

  // Test minting multiple tokens
  it("should mint multiple tokens to a valid address", async () => {
    const numberOfTokens = 3;
    const receipt = await myTokenInstance.mintMultiple(nonOwner, numberOfTokens, { from: owner });

    // Check that the Transfer events were emitted for each token
    for (let i = 0; i < numberOfTokens; i++) {
      assert.equal(receipt.logs[i].event, "Transfer", "Transfer event should be emitted");
      assert.equal(receipt.logs[i].args.to, nonOwner, "Token should be minted to the correct address");
      assert.equal(receipt.logs[i].args.tokenId.toNumber(), i, "Token ID should be correct");
    }

    // Check that the tokens exist and are owned by the correct address
    for (let i = 0; i < numberOfTokens; i++) {
      const ownerOfToken = await myTokenInstance.getOwner(i);
      assert.equal(ownerOfToken, nonOwner, `The owner of token ${i} should be the correct address`);
    }
  });

  // Test that minting to the zero address fails
  it("should fail to mint a token to the zero address", async () => {
    try {
      await myTokenInstance.mintNFT(zeroAddress, { from: owner });
      assert.fail("Minting to the zero address should fail");
    } catch (error) {
      assert(error.message.includes("Error: Invalid address"), "Expected invalid address error");
    }
  });

  // Test that only the owner can mint tokens
  it("should only allow the owner to mint tokens", async () => {
    try {
      await myTokenInstance.mintNFT(nonOwner, { from: nonOwner });
      assert.fail("Non-owner should not be able to mint tokens");
    } catch (error) {
      assert(error.message.includes("Caller is not the owner"), "Expected onlyOwner error");
    }
  });

  // Test transferring ownership to a valid address
  it("should transfer ownership to a valid address", async () => {
    const newOwner = accounts[2];
    await myTokenInstance.transferOwnership(newOwner, { from: owner });

    // Check that the ownership was transferred
    const currentOwner = await myTokenInstance.owner();
    assert.equal(currentOwner, newOwner, "Ownership should be transferred to the new owner");
  });

  // Test that transferring ownership to the zero address fails
  it("should fail to transfer ownership to the zero address", async () => {
    try {
      await myTokenInstance.transferOwnership(zeroAddress, { from: owner });
      assert.fail("Transferring ownership to the zero address should fail");
    } catch (error) {
      assert(error.message.includes("New owner is the zero address"), "Expected zero address error");
    }
  });

  // Test that only the owner can transfer ownership
  it("should only allow the owner to transfer ownership", async () => {
    const newOwner = accounts[2];
    try {
      await myTokenInstance.transferOwnership(newOwner, { from: nonOwner });
      assert.fail("Non-owner should not be able to transfer ownership");
    } catch (error) {
      assert(error.message.includes("Caller is not the owner"), "Expected onlyOwner error");
    }
  });

  // Test checking ownership of a specific token
  it("should return true if the address owns the token", async () => {
    await myTokenInstance.mintNFT(nonOwner, { from: owner });
    const isOwner = await myTokenInstance.isOwnerOf(nonOwner, 0);
    assert.equal(isOwner, true, "The address should own the token");
  });

  // Test checking ownership of a token that does not exist
  it("should return false if the address does not own the token", async () => {
    const isOwner = await myTokenInstance.isOwnerOf(nonOwner, 0);
    assert.equal(isOwner, false, "The address should not own the token");
  });

  // Test minting a token that has already been minted
  it("should fail to mint a token that has already been minted", async () => {
    await myTokenInstance.mintNFT(nonOwner, { from: owner });
    try {
      await myTokenInstance.mintNFT(nonOwner, { from: owner });
      assert.fail("Minting an already minted token should fail");
    } catch (error) {
      assert(error.message.includes("Error: Token has already been minted"), "Expected token already minted error");
    }
  });

  // Test transferring a token to another account
  it("should transfer a token to another account", async () => {
    await myTokenInstance.mintNFT(nonOwner, { from: owner });
    const tokenId = 0;

    // Transfer the token from nonOwner to anotherAccount
    await myTokenInstance.transferOwnership(anotherAccount, { from: nonOwner });

    // Check that the token is now owned by anotherAccount
    const ownerOfToken = await myTokenInstance.getOwner(tokenId);
    assert.equal(ownerOfToken, anotherAccount, "The token should be transferred to the new owner");
  });

  // Test transferring a token that does not exist
  it("should fail to transfer a token that does not exist", async () => {
    try {
      await myTokenInstance.transferOwnership(anotherAccount, { from: nonOwner });
      assert.fail("Transferring a non-existent token should fail");
    } catch (error) {
      assert(error.message.includes("Error: The requested token does not exist"), "Expected token does not exist error");
    }
  });

  // Test minting tokens after ownership transfer
  it("should allow the new owner to mint tokens after ownership transfer", async () => {
    const newOwner = accounts[2];
    await myTokenInstance.transferOwnership(newOwner, { from: owner });

    // New owner mints a token
    const receipt = await myTokenInstance.mintNFT(nonOwner, { from: newOwner });
    const tokenId = 0;

    // Check that the Transfer event was emitted
    assert.equal(receipt.logs[0].event, "Transfer", "Transfer event should be emitted");
    assert.equal(receipt.logs[0].args.to, nonOwner, "Token should be minted to the correct address");
    assert.equal(receipt.logs[0].args.tokenId.toNumber(), tokenId, "Token ID should be correct");

    // Check that the token exists and is owned by the correct address
    const ownerOfToken = await myTokenInstance.getOwner(tokenId);
    assert.equal(ownerOfToken, nonOwner, "The owner of the token should be the correct address");
  });

  // Test that the original owner cannot mint tokens after ownership transfer
  it("should not allow the original owner to mint tokens after ownership transfer", async () => {
    const newOwner = accounts[2];
    await myTokenInstance.transferOwnership(newOwner, { from: owner });

    try {
      await myTokenInstance.mintNFT(nonOwner, { from: owner });
      assert.fail("Original owner should not be able to mint tokens after ownership transfer");
    } catch (error) {
      assert(error.message.includes("Caller is not the owner"), "Expected onlyOwner error");
    }
  });
});
