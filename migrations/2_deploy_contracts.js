
// Huang SiTing（A0254423L）
// Chua Yong Keng (A0254424J)
// Liu Yaqi (A0254426E)
// Tan Hong Jie Uriel (A0184411M)

const Hats = artifacts.require("./hats");
const Pfp = artifacts.require("./bayc");

module.exports = (deployer, network, accounts) => {
    deployer.deploy(Pfp).then(() => {
        return deployer.deploy(Hats, 1, Pfp.address);
    });
}