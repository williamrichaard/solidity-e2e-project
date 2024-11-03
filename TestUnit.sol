const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
    const owner = accounts[0];
    const user1 = accounts[1];

    let myTokenInstance;

    beforeEach(async () => {
        myTokenInstance = await MyToken.new(owner);
    });

    it("should deploy the contract and set the correct owner", async () => {
        const contractOwner = await myTokenInstance.owner();
        assert.equal(contractOwner, owner, "Owner is not set correctly");
    });

    it("should mint a new NFT and assign it to the correct owner", async () => {
        await myTokenInstance.mintNFT(user1, { from: owner });
        const tokenOwner = await myTokenInstance.getOwner(0);
        assert.equal(tokenOwner, user1, "Token owner is not set correctly");
    });

    it("should not allow non-owners to mint NFTs", async () => {
        try {
            await myTokenInstance.mintNFT(user1, { from: user1 });
            assert.fail("Non-owner was able to mint an NFT");
        } catch (error) {
            assert(error.message.includes("Caller is not the owner"), "Expected onlyOwner modifier to fail");
        }
    });

    it("should transfer ownership of the contract", async () => {
        await myTokenInstance.transferOwnership(user1, { from: owner });
        const newOwner = await myTokenInstance.owner();
        assert.equal(newOwner, user1, "Ownership was not transferred correctly");
    });

    it("should not allow non-owners to transfer ownership", async () => {
        try {
            await myTokenInstance.transferOwnership(user1, { from: user1 });
            assert.fail("Non-owner was able to transfer ownership");
        } catch (error) {
            assert(error.message.includes("Caller is not the owner"), "Expected onlyOwner modifier to fail");
        }
    });
});
