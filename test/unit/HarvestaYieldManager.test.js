const { network, ethers, getNamedAccounts, deployments } = require("hardhat");
const { expect, assert } = require("chai");
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("HarvestaYieldManager Unit Test", () => {
      let harvestaManager, deployer, accounts, tokenWhale, DCHFToken, chainId;

      beforeEach(async () => {
        accounts = await ethers.getSigners();
        deployer = (await getNamedAccounts()).deployer;

        await deployments.fixture(["all"]);

        harvestaManager = await ethers.getContract(
          "HarvestaYieldManager",
          deployer
        );

        chainId = network.config.chainId;

        const tokenAddress = networkConfig[chainId].DCHFToken;
        DCHFToken = await ethers.getContractAt("IDCHFToken", tokenAddress);

        const whaleAddress = networkConfig[chainId].DCHFWhale;
        await helpers.impersonateAccount(whaleAddress);
        tokenWhale = await ethers.getSigner(whaleAddress);
      });

      describe("#fetchAssetPrice", () => {
        it("successfully fetch the price of ETH/USD from ChainLink PriceFeed", async () => {
          const price = await harvestaManager.fetchAssetPrice(
            ethers.constants.AddressZero
          );

          console.log(ethers.utils.formatEther(price));
        });
      });

      describe("#_transferAvailableTokensToStabilityPool", () => {
        it("successfully transfer the DCHF to the stability Pool", async () => {
          const tokenAmount = ethers.utils.parseEther("10000");
          await DCHFToken.connect(tokenWhale).transfer(
            harvestaManager.address,
            tokenAmount
          );

          await harvestaManager._transferAvailableTokensToStabilityPool(
            ethers.constants.AddressZero
          );

          const stabilityPoolAddress = networkConfig[chainId].StabilityPoolETH;

          const stabilityPool = await ethers.getContractAt(
            "IStabilityPool",
            stabilityPoolAddress
          );

          const _depositTokens = await stabilityPool.getCompoundedDCHFDeposit(
            harvestaManager.address
          );

          assert(_depositTokens.eq(tokenAmount));
        });
      });
    });
