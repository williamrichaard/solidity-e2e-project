const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
  let myTokenInstance;
  const owner = accounts[0]; // Owner account
  const minter = accounts[1]; // Authorized minter
  const nonMinter = accounts[2]; // Non-authorized account
  const anotherAccount = accounts[3]; // Another account

  beforeEach(async () => {
    myTokenInstance = await MyToken.new(owner, { from: owner });
  });

  it("should mint a new token to the authorized address", async () => {
    await myTokenInstance.authorizeMinter(minter, { from: owner });
    await myTokenInstance.mintNFT(minter, { from: minter });

    const ownerOfToken = await myTokenInstance.getOwner(0);
    assert.equal(ownerOfToken, minter, "Minter should own the token");
  });

  it("should fail to mint a token if not authorized", async () => {
    try {
      await myTokenInstance.mintNFT(nonMinter, { from: nonMinter });
      assert.fail("Non-authorized address should not be able to mint tokens");
    } catch (error) {
      assert(error.message.includes("Caller is not an authorized minter"));
    }
  });

  it("should transfer ownership correctly", async () => {
    const newOwner = accounts[4];
    await myTokenInstance.transferOwnership(newOwner, { from: owner });

    const currentOwner = await myTokenInstance.owner();
    assert.equal(currentOwner, newOwner, "Ownership should have transferred");
  });

  it("should return the correct owner of a specific token", async () => {
    await myTokenInstance.mintNFT(minter, { from: owner });
    const ownerOfToken = await myTokenInstance.getOwner(0);
    assert.equal(ownerOfToken, minter, "Owner of token should be correct");
  });
});
