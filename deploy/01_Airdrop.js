
module.exports = async function ({ ethers, getNamedAccounts, deployments, getChainId }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()

    const owner = deployer
    const airdropToken = deployments.get("AirdropToken");
    console.log(`Airdrop token is at: ${airdropToken.address}`);

    const airdrop = await deploy("Airdrop", {
      from: deployer,
      args: [airdropToken.address, owner],
      log: true,
      deterministicDeployment: true,
    })
  }
  
  module.exports.tags = ["Airdrop"]
  