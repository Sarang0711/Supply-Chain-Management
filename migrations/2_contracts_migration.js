const erc20Token = artifacts.require("ERC20Token");
const SupplyChain = artifacts.require("SupplyChain");
const basicMath = artifacts.require("basicMath");

module.exports = function (deployer) {
    deployer.deploy(erc20Token, 10000, "TotalSem Token", 18, "TotalSem");
    deployer.deploy(SupplyChain);
    deployer.deploy(basicMath);
};