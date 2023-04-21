
// Huang SiTing（A0254423L）
// Chua Yong Keng (A0254424J)
// Liu Yaqi (A0254426E)
// Tan Hong Jie Uriel (A0184411M)

const PfpContract = artifacts.require("PfpContract");
const HatsNFT = artifacts.require("HatsNFT");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(PfpContract).then(() => {
        return deployer.deploy(HatsNFT);
    });
}