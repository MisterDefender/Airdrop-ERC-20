const { ethers } = require("hardhat");

module.exports = async function ({
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const owner = deployer;
  const airdropToken = await deployments.get("AirdropToken");
  console.log(`Airdrop token is at: ${airdropToken.address}`);

  const airdrop = await deploy("Airdrop", {
    from: deployer,
    args: [airdropToken.address, owner, ethers.parseEther("10")],
    log: true,
    deterministicDeployment: true,
  });
};

module.exports.tags = ["Airdrop"];
