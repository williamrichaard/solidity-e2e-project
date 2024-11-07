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

    assert.equal(receipt.logs[0].event, "Transfer", "Transfer event should be emitted");
    assert.equal(receipt.logs[0].args.to, nonOwner, "Token should be minted to the correct address");
    assert.equal(receipt.logs[0].args.tokenId.toNumber(), tokenId, "Token ID should be correct");

    const ownerOfToken = await myTokenInstance.getOwner(tokenId);
    assert.equal(ownerOfToken, nonOwner, "The owner of the token should be the correct address");
  });

  // Test minting multiple tokens
  it("should mint multiple tokens to a valid address", async () => {
    const numberOfTokens = 3;
    const receipt = await myTokenInstance.mintMultiple(nonOwner, numberOfTokens, { from: owner });

    for (let i = 0; i < numberOfTokens; i++) {
      assert.equal(receipt.logs[i].event, "Transfer", "Transfer event should be emitted");
      assert.equal(receipt.logs[i].args.to, nonOwner, "Token should be minted to the correct address");
      assert.equal(receipt.logs[i].args.tokenId.toNumber(), i, "Token ID should be correct");
    }

    for (let i = 0; i < numberOfTokens; i++) {
      const ownerOfToken = await myTokenInstance.getOwner(i);
      assert.equal(ownerOfToken, nonOwner, `The owner of token ${i} should be the correct address`);
    }
  });

  // Test minting to the zero address fails
  it("should fail to mint a token to the zero address", async () => {
    try {
      await myTokenInstance.mintNFT(zeroAddress, { from: owner });
      assert.fail("Minting to the zero address should fail");
    } catch (error) {
      assert(error.message.includes("Cannot mint to the zero address"), "Expected invalid address error");
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

  // Test transferring ownership
  it("should transfer ownership to a valid address", async () => {
    const newOwner = accounts[2];
    await myTokenInstance.transferOwnership(newOwner, { from: owner });

    const currentOwner = await myTokenInstance.owner();
    assert.equal(currentOwner, newOwner, "Ownership should be transferred to the new owner");
  });
});
