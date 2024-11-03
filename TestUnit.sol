const MyToken = artifacts.require("MyToken");
const { expect } = require("chai");

contract("MyToken", (accounts) => {
    const [owner, user1, user2] = accounts;
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

    it("should emit a Transfer event when minting a new NFT", async () => {
        const receipt = await myTokenInstance.mintNFT(user1, { from: owner });
        expect(receipt.logs.length).to.equal(1);
        const event = receipt.logs[0];
        expect(event.event).to.equal("Transfer");
        expect(event.args.from).to.equal("0x0000000000000000000000000000000000000000");
        expect(event.args.to).to.equal(user1);
        expect(event.args.tokenId.toNumber()).to.equal(0);
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

    it("should emit an OwnershipTransferred event when ownership is transferred", async () => {
        const receipt = await myTokenInstance.transferOwnership(user1, { from: owner });
        expect(receipt.logs.length).to.equal(1);
        const event = receipt.logs[0];
        expect(event.event).to.equal("OwnershipTransferred");
        expect(event.args.previousOwner).to.equal(owner);
        expect(event.args.newOwner).to.equal(user1);
    });

    it("should not allow non-owners to transfer ownership", async () => {
        try {
            await myTokenInstance.transferOwnership(user1, { from: user1 });
            expect.fail("Non-owner was able to transfer ownership");
        } catch (error) {
            expect(error.message).to.include("Caller is not the owner");
        }
    });

    it("should revert if trying to transfer ownership to the zero address", async () => {
        try {
            await myTokenInstance.transferOwnership("0x0000000000000000000000000000000000000000", { from: owner });
            expect.fail("Ownership was transferred to the zero address");
        } catch (error) {
            expect(error.message).to.include("New owner is the zero address");
        }
    });

    it("should revert if trying to mint to the zero address", async () => {
        try {
            await myTokenInstance.mintNFT("0x0000000000000000000000000000000000000000", { from: owner });
            expect.fail("NFT was minted to the zero address");
        } catch (error) {
            expect(error.message).to.include("Cannot mint to the zero address");
        }
    });

    it("should not allow minting of already minted tokens", async () => {
        await myTokenInstance.mintNFT(user1, { from: owner });
        try {
            await myTokenInstance.mintNFT(user1, { from: owner });
            expect.fail("Token was minted twice");
        } catch (error) {
            expect(error.message).to.include("Token already minted");
        }
    });
});
