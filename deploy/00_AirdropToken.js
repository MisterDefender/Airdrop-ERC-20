module.exports = async function ({
  ethers,
  getNamedAccounts,
  deployments,
  getChainId,
}) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const owner = deployer;
  const initialSupply = ethers.utils.parseEther("1000");
  
  const airdropToken = await deploy("AirdropToken", {
    from: deployer,
    args: [owner, initialSupply],
    log: true,
    deterministicDeployment: true,
  });
};

module.exports.tags = ["AirdropToken"];
