const { network } = require("hardhat");
const { networkConfig } = require("../helper-hardhat-config");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const chainId = network.config.chainId;

  if (chainId in networkConfig) {
    const borrowerOperationsAddress = networkConfig[chainId].borrowerOperations;

    const hintHelpersAddress = networkConfig[chainId].hintHelpers;

    const troveManagerHelpersAddress =
      networkConfig[chainId].troveManagerHelper;

    const args = [
      borrowerOperationsAddress,
      hintHelpersAddress,
      troveManagerHelpersAddress,
    ];

    await deploy("HarvestaStaking", { from: deployer, log: true, args: args });
  }
};

module.exports.tags = ["staking", "all"];
