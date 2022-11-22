module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deployer } = await getNamedAccounts();
  const { deploy, log } = deployments;

  await deploy("YieldPool", { from: deployer, log: true, args: [] });
};

module.exports.tags = ["yield-pool", "all"];
