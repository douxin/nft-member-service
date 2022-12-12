import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Merchant", function () {
    async function deployMerchant() {
        const [owner, mchUser] = await ethers.getSigners();
        const decimal = 10 ** 4;

        const Merchant = await ethers.getContractFactory("Merchant");
        const merchant = await Merchant.deploy("Startbuck", "STB", 10*decimal, 100*decimal);

        return {merchant, owner, mchUser};
    }

    describe("Deployment", function () {
        it("Owner setup correct", async function () {
            const { owner, merchant } = await loadFixture(deployMerchant);

            expect(await merchant.owner()).to.equal(owner.address);
        });

        it('Merchant Info setup correct', async function () {
            const {merchant} = await loadFixture(deployMerchant);
            const mch = await merchant.getMerchantInfo();
            expect(mch.name).to.equal('Startbuck');
            expect(mch.symbol).to.equal('STB');
        });
    });
});
