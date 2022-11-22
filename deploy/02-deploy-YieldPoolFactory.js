const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  const yieldPoolAddress = await deployments.get("YieldPool");
  console.log(yieldPoolAddress);
  await deploy("YieldPoolFactory", { from: deployer, log: true, args: [] });
};
