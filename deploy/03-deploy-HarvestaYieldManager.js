const { network } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const chainId = network.config.chainId;

  if (chainId in networkConfig) {
    const stabilityPoolManagerAddress =
      networkConfig[chainId].stabilityPoolManager;

    const DCHFTokenAddress = networkConfig[chainId].DCHFToken;

    const priceFeedAddress = networkConfig[chainId].priceFeed;

    const args = [
      DCHFTokenAddress,
      stabilityPoolManagerAddress,
      priceFeedAddress,
    ];

    await deploy("HarvestaYieldManager", {
      from: deployer,
      log: true,
      args: args,
    });
  } else {
    console.log(
      `Attention. No Config is setup for the network ${network.name} `
    );
  }
};

module.exports.tags = ["yield-manager", "all"];
