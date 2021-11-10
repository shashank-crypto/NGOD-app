const NgoFundManagement = artifacts.require("NgoFundManagement");

module.exports = function (deployer) {
  deployer.deploy(NgoFundManagement);
};
