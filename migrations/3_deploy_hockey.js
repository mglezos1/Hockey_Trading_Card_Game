const Hockey = artifacts.require("Hockey");
module.exports = (deployer) => {
  deployer.deploy(Hockey);
};
