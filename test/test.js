// SPDX-License-Identifier: MIT
const _deploy_contracts = require("../migrations/2_deploy_contracts.js");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const Hats = artifacts.require("HatsNFT");
const Pfp = artifacts.require("PfpContract");

contract("NFTAttach", (accounts) => {
    let nft1;
    let nft2;
    const owner = accounts[0];
    const addr1 = accounts[1];
    const addr2 = accounts[2];
    const tokenId1 = 0;
    const tokenId2 = 0;

    beforeEach(async () => {
        nft1 = await Hats.new();
        nft2 = await Pfp.new();
        await nft1.mintHat(accounts[1], "Cap", "Bunny", "Blue", 1, { from: accounts[0] });
        await nft2.mint(accounts[1], { from: accounts[0] });
    });

    it("should attach an NFT", async () => {
        // Attach NFT2 to NFT1]
        let attachment = await nft1.attachHat(tokenId1, tokenId2, nft2.address, { from: accounts[1] });

        truffleAssert.eventEmitted(attachment, 'HatAttached', (ev) => {
            assert (ev.hatId == tokenId1);
            assert (ev.tokenId == tokenId2);
            assert (ev.owner == nft2.address);
            return true;
        });
    });

    it("should detach an NFT", async () => {
        await nft1.attachHat(tokenId1, tokenId2, nft2.address, { from: accounts[1] });

        let detachment = await nft1.detachHat(tokenId1, { from: accounts[1] });

        truffleAssert.eventEmitted(detachment, 'HatDetached', (ev) => {
            assert (ev.hatId == tokenId1);
            return true;
        });
    });

    it("check tokenURI", async () => {
        let tokenURI1 = await nft1.tokenURI(tokenId1);
        assert.equal(tokenURI1.toString(),'{"name":"Cap","description":"Bunny","attributes":[{"trait_type":"color","value":"Blue"},{"trait_type":"rarity","value":1}],"image":"ipfs://.png"}', tokenURI1);
        await nft1.attachHat(tokenId1, tokenId2, nft2.address, { from: accounts[1] });
        
        let tokenURI2 = await nft1.tokenURI(tokenId1);
        assert.equal(tokenURI2, '{"name":"Cap","description":"Bunny","attributes":[{"trait_type":"color","value":"Blue"},{"trait_type":"rarity","value":1}],"image":"example.com/.png","pfp":ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/0}', tokenURI2);
    });
});
