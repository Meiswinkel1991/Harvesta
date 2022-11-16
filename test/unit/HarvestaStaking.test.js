const { network, ethers, getNamedAccounts, deployments } = require("hardhat");
const { expect, assert } = require("chai");

const {
  developmentChains,
  networkConfig,
} = require("../../helper-hardhat-config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("HarvestaStaking Unit Test", () => {
      let harvestaStaking, deployer, accounts, collEther, troveManagerHelpers;

      beforeEach(async () => {
        accounts = await ethers.getSigners();
        deployer = (await getNamedAccounts()).deployer;

        await deployments.fixture(["all"]);

        harvestaStaking = await ethers.getContract("HarvestaStaking", deployer);

        const troveManagerHelpersAddress =
          networkConfig[network.config.chainId].troveManagerHelper;

        troveManagerHelpers = await ethers.getContractAt(
          "ITroveManagerHelpers",
          troveManagerHelpersAddress
        );

        //sending Ether to the contract
        collEther = ethers.utils.parseEther("20");
        const _fiveBigNo = ethers.BigNumber.from("5");
        await accounts[0].sendTransaction({
          to: harvestaStaking.address,
          value: collEther.mul(_fiveBigNo),
        });
      });

      describe("#openTrove", () => {
        it("successfully open a new trove", async () => {
          const etherAddress = ethers.constants.AddressZero;
          const amountDebt = ethers.utils.parseEther("2000");
          await harvestaStaking.openTrove(etherAddress, collEther, amountDebt);

          const troveColl = await troveManagerHelpers.getTroveColl(
            etherAddress,
            harvestaStaking.address
          );

          assert(troveColl.eq(collEther));
        });

        it("failed to open a new trove twice", async () => {
          const etherAddress = ethers.constants.AddressZero;
          const amountDebt = ethers.utils.parseEther("2000");
          await harvestaStaking.openTrove(etherAddress, collEther, amountDebt);

          await expect(
            harvestaStaking.openTrove(etherAddress, collEther, amountDebt)
          ).to.be.revertedWithCustomError(
            harvestaStaking,
            "HarvestaStaking__TroveIsActive"
          );
        });
      });
    });
