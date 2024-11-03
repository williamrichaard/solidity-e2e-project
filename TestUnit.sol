const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
  const [owner, user1, user2] = accounts;

  it("should mint a new NFT", async () => {
    const instance = await MyToken.new(owner);
    await instance.mintNFT(user1, { from: owner });
    const ownerOfToken = await instance.getOwner(0);
    assert.equal(ownerOfToken, user1, "The owner of the token should be user1");
  });

  it("should transfer ownership of the contract", async () => {
    const instance = await MyToken.new(owner);
    await instance.transferOwnership(user2, { from: owner });
    const newOwner = await instance.owner();
    assert.equal(newOwner, user2, "The new owner should be user2");
  });

  it("should not allow unauthorized users to mint NFTs", async () => {
    const instance = await MyToken.new(owner);
    try {
      await instance.mintNFT(user1, { from: user1 });
      assert.fail("Unauthorized user was able to mint an NFT");
    } catch (error) {
      assert(
        error.message.includes("Caller is not authorized"),
        "Expected 'Caller is not authorized' error"
      );
    }
  });
});
