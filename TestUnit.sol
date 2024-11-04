
const MyToken = artifacts.require("MyToken");

contract("MyToken", (accounts) => {
    let myTokenInstance;
    const owner = accounts[0];
    const nonOwner = accounts[1];
    const zeroAddress = "0x0000000000000000000000000000000000000000";

    beforeEach(async () => {
        myTokenInstance = await MyToken.new({ from: owner });
    });

    it("should mint a new token to a valid address", async () => {
        const receipt = await myTokenInstance.mintNFT(nonOwner, { from: owner });
        const tokenId = 0;

        // Check that the event was emitted
        assert.equal(receipt.logs[0].event, "TokenMinted", "TokenMinted event should be emitted");
        assert.equal(receipt.logs[0].args.to, nonOwner, "Token should be minted to the correct address");
        assert.equal(receipt.logs[0].args.tokenId.toNumber(), tokenId, "Token ID should be correct");

        // Check that the token exists
        const ownerOfToken = await myTokenInstance.ownerOf(tokenId);
        assert.equal(ownerOfToken, nonOwner, "The owner of the token should be the correct address");
    });

    it("should fail to mint a token to the zero address", async () => {
        try {
            await myTokenInstance.mintNFT(zeroAddress, { from: owner });
            assert.fail("Minting to the zero address should fail");
        } catch (error) {
            assert(error.message.includes("Error: Invalid address"), "Expected invalid address error");
        }
    });

    it("should only allow the owner to mint tokens", async () => {
        try {
            await myTokenInstance.mintNFT(nonOwner, { from: nonOwner });
            assert.fail("Non-owner should not be able to mint tokens");
        } catch (error) {
            assert(error.message.includes("Ownable: caller is not the owner"), "Expected onlyOwner error");
        }
    });

    it("should transfer ownership to a valid address", async () => {
        const newOwner = accounts[2];
        await myTokenInstance.transferOwnership(newOwner, { from: owner });

        const currentOwner = await myTokenInstance.getOwner();
        assert.equal(currentOwner, newOwner, "Ownership should be transferred to the new owner");
    });

    it("should fail to transfer ownership to the zero address", async () => {
        try {
            await myTokenInstance.transferOwnership(zeroAddress, { from: owner });
            assert.fail("Transferring ownership to the zero address should fail");
        } catch (error) {
            assert(error.message.includes("Error: New owner is the zero address"), "Expected zero address error");
        }
    });

    it("should only allow the owner to transfer ownership", async () => {
        const newOwner = accounts[2];
        try {
            await myTokenInstance.transferOwnership(newOwner, { from: nonOwner });
            assert.fail("Non-owner should not be able to transfer ownership");
        } catch (error) {
            assert(error.message.includes("Ownable: caller is not the owner"), "Expected onlyOwner error");
        }
    });
});