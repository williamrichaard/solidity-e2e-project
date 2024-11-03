const { expect } = require("chai");
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
        expect(contractOwner).to.equal(owner);
    });

    it("should mint a new NFT and assign it to the correct owner", async () => {
        await myTokenInstance.mintNFT(user1, { from: owner });
        const tokenOwner = await myTokenInstance.getOwner(0);
        expect(tokenOwner).to.equal(user1);
    });

    it("should not allow non-owners to mint NFTs", async () => {
        try {
            await myTokenInstance.mintNFT(user1, { from: user1 });
            expect.fail("Non-owner was able to mint an NFT");
        } catch (error) {
            expect(error.message).to.include("Caller is not the owner");
        }
    });

    it("should transfer ownership of the contract", async () => {
        await myTokenInstance.transferOwnership(user1, { from: owner });
        const newOwner = await myTokenInstance.owner();
        expect(newOwner).to.equal(user1);
    });

    it("should not allow non-owners to transfer ownership", async () => {
        try {
            await myTokenInstance.transferOwnership(user1, { from: user1 });
            expect.fail("Non-owner was able to transfer ownership");
        } catch (error) {
            expect(error.message).to.include("Caller is not the owner");
        }
    });

    it("should not mint a token to the zero address", async () => {
        try {
            await myTokenInstance.mintNFT("0x0000000000000000000000000000000000000000", { from: owner });
            expect.fail("Minting to zero address was allowed");
        } catch (error) {
            expect(error.message).to.include("Error: Invalid address. Cannot mint to the zero address.");
        }
    });

    it("should not allow querying a non-existent token", async () => {
        try {
            await myTokenInstance.getOwner(999);
            expect.fail("Querying non-existent token was allowed");
        } catch (error) {
            expect(error.message).to.include("Error: The requested token does not exist.");
        }
    });
});
