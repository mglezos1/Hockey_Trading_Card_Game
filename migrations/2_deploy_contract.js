 const ERC721Contract = artifacts.require("ERC721Contract");
module.exports = (deployer, _network) => {
  deployer.deploy(ERC721Contract);
};