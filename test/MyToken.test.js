const ERC721Token = artifacts.require("ERC721Token");

contract("ERC721Token", (accounts) => {
  let tokenInstance;
  const owner = accounts[0]; // Owner account
  const minter = accounts[1]; // Authorized minter
  const nonMinter = accounts[2]; // Non-authorized account
  const anotherAccount = accounts[3]; // Another account
  const maxSupply = 10000; // Max supply set in contract

  beforeEach(async () => {
    tokenInstance = await ERC721Token.new(owner, { from: owner });
  });

  it("should mint a new token to an authorized minter", async () => {
    await tokenInstance.authorizeMinter(minter, { from: owner });
    await tokenInstance.mintNFT(minter, { from: minter });

    const ownerOfToken = await tokenInstance.getOwner(0);
    assert.equal(ownerOfToken, minter, "Minter should own the token");
  });

  it("should fail to mint a token if not authorized", async () => {
    try {
      await tokenInstance.mintNFT(nonMinter, { from: nonMinter });
      assert.fail("Non-authorized address should not be able to mint tokens");
    } catch (error) {
      assert(error.message.includes("Caller is not an authorized minter"));
    }
  });

  it("should fail to mint if max supply is reached", async () => {
    // Mint max supply
    for (let i = 0; i < maxSupply; i++) {
      await tokenInstance.mintNFT(owner, { from: minter });
    }
    try {
      await tokenInstance.mintNFT(owner, { from: minter });
      assert.fail("Minting should fail after max supply is reached");
    } catch (error) {
      assert(error.message.includes("Max supply reached"));
    }
  });

  it("should transfer ownership correctly", async () => {
    const newOwner = accounts[4];
    await tokenInstance.transferOwnership(newOwner, { from: owner });

    const currentOwner = await tokenInstance.owner();
    assert.equal(currentOwner, newOwner, "Ownership should have transferred");
  });

  it("should return the correct owner of a specific token", async () => {
    await tokenInstance.authorizeMinter(minter, { from: owner });
    await tokenInstance.mintNFT(minter, { from: minter });
    const ownerOfToken = await tokenInstance.getOwner(0);
    assert.equal(ownerOfToken, minter, "Owner of token should be correct");
  });

  it("should fail to mint to the zero address", async () => {
    try {
      await tokenInstance.mintNFT("0x0000000000000000000000000000000000000000", { from: minter });
      assert.fail("Minting to zero address should fail");
    } catch (error) {
      assert(error.message.includes("Cannot mint to the zero address"));
    }
  });

  it("should authorize and revoke a minter correctly", async () => {
    await tokenInstance.authorizeMinter(anotherAccount, { from: owner });
    await tokenInstance.mintNFT(anotherAccount, { from: anotherAccount });

    const ownerOfToken = await tokenInstance.getOwner(1);
    assert.equal(ownerOfToken, anotherAccount, "Another account should own the token");

    // Revoke minter and check that minting is now disallowed
    await tokenInstance.revokeMinter(anotherAccount, { from: owner });

    try {
      await tokenInstance.mintNFT(anotherAccount, { from: anotherAccount });
      assert.fail("Revoked minter should not be able to mint tokens");
    } catch (error) {
      assert(error.message.includes("Caller is not an authorized minter"));
    }
  });
});
