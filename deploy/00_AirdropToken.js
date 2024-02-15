const { ethers } = require("hardhat");

module.exports = async function ({
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const owner = deployer;
  const initialSupply = ethers.parseEther("1000");

  const airdropToken = await deploy("AirdropToken", {
    from: deployer,
    args: [owner, initialSupply],
    log: true,
    deterministicDeployment: true,
  });
};

module.exports.tags = ["AirdropToken"];
