
const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
  const [owner, newOwner, user1, user2] = accounts;

  let myTokenInstance;

  beforeEach(async () => {
    myTokenInstance = await MyToken.new(owner);
  });

  it("should initialize the contract with the correct owner", async () => {
    const contractOwner = await myTokenInstance.owner();
    assert.equal(contractOwner, owner, "Owner is not set correctly");
  });

  it("should allow the owner to mint a new NFT", async () => {
    await myTokenInstance.mintNFT(user1, { from: owner });
    const tokenOwner = await myTokenInstance.getOwner(0);
    assert.equal(tokenOwner, user1, "Token was not minted correctly");
  });

  it("should not allow non-owners to mint NFTs", async () => {
    try {
      await myTokenInstance.mintNFT(user1, { from: user2 });
      assert.fail("Non-owner was able to mint an NFT");
    } catch (error) {
      assert(
        error.message.includes("Caller is not the owner"),
        "Expected onlyOwner modifier to prevent minting"
      );
    }
  });

  it("should allow the owner to transfer ownership", async () => {
    await myTokenInstance.transferOwnership(newOwner, { from: owner });
    const contractOwner = await myTokenInstance.owner();
    assert.equal(contractOwner, newOwner, "Ownership was not transferred correctly");
  });

  it("should not allow non-owners to transfer ownership", async () => {
    try {
      await myTokenInstance.transferOwnership(newOwner, { from: user1 });
      assert.fail("Non-owner was able to transfer ownership");
    } catch (error) {
      assert(
        error.message.includes("Caller is not the owner"),
        "Expected onlyOwner modifier to prevent ownership transfer"
      );
    }
  });

  it("should not allow minting to the zero address", async () => {
    try {
      await myTokenInstance.mintNFT("0x0000000000000000000000000000000000000000", { from: owner });
      assert.fail("Minting to zero address was allowed");
    } catch (error) {
      assert(
        error.message.includes("Cannot mint to the zero address"),
        "Expected minting to zero address to fail"
      );
    }
  });

  it("should not allow querying ownership of non-existent tokens", async () => {
    try {
      await myTokenInstance.getOwner(999);
      assert.fail("Querying non-existent token did not fail");
    } catch (error) {
      assert(
        error.message.includes("The requested token does not exist"),
        "Expected querying non-existent token to fail"
      );
    }
  });
});
