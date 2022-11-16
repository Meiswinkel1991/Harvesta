const { networkConfig } = require("../helper-hardhat-config");

task("openTrove", "open a defifranc trove").setAction(async () => {
  const utils = hre.ethers.utils;

  const DCHFAmount = utils.parseEther("2500");
  const ETHColl = utils.parseEther("5");

  const liquidationReserve = utils.parseEther("200");

  const etherAddress = hre.ethers.constants.AddressZero;

  const chainId = hre.network.config.chainId;

  console.log(
    `Try to open a trove with ${utils.formatEther(ETHColl)} ${
      hre.ethers.constants.EtherSymbol
    } and a debt of ${utils.formatEther(DCHFAmount)} DCHF`
  );

  if (chainId in networkConfig) {
    const troveManagerHelpersAddress =
      networkConfig[chainId].troveManagerHelper;
    const troveManagerHelpers = await hre.ethers.getContractAt(
      "ITroveManagerHelpers",
      troveManagerHelpersAddress
    );

    const expectedFee = await troveManagerHelpers.getBorrowingFee(
      etherAddress,
      DCHFAmount
    );

    const expectedDebt = DCHFAmount.add(liquidationReserve).add(expectedFee);

    console.log(
      `The expected debt is ${utils.formatEther(expectedDebt)} DCHF.`
    );

    //Get the nominal NICR of the new trove

    const _1e20 = utils.parseEther("100");
    const NICR = ETHColl.mul(_1e20).div(expectedDebt);

    console.log(`The nominal ICR is ${utils.formatEther(NICR)}`);

    const sortedTrovesAddress = networkConfig[chainId].sortedTroves;
    const sortedTroves = await hre.ethers.getContractAt(
      "ISortedTroves",
      sortedTrovesAddress
    );
    const hintHelpersAddress = networkConfig[chainId].hintHelpers;
    const hintHelpers = await hre.ethers.getContractAt(
      "IHintHelpers",
      hintHelpersAddress
    );

    const numTroves = await sortedTroves.getSize(etherAddress);

    const numTrials = numTroves.mul(hre.ethers.BigNumber.from("15"));

    const computeNNCR = await hintHelpers.computeNominalCR(ETHColl, DCHFAmount);
    console.log(utils.formatEther(computeNNCR));
    console.log(etherAddress, NICR.toString(), numTrials.toString());

    // const answer = await hintHelpers.getApproxHint(
    //   etherAddress,
    //   NICR,
    //   numTrials,
    //   42
    // );

    // console.log(answer);

    const borrowerOperationsAddress = networkConfig[chainId].borrowerOperations;
    const borrowerOperations = await hre.ethers.getContractAt(
      "IBorrowerOperations",
      borrowerOperationsAddress
    );

    const maxFee = utils.parseEther("0.050");

    /**
     * function openTrove(
        address _asset,
        uint256 _tokenAmount,
        uint256 _maxFee,
        uint256 _DCHFamount,
        address _upperHint,
        address _lowerHint
    ) external payable;
     */
    const [signer] = await hre.ethers.getSigners();
    console.log(signer.address);
    const tx = await borrowerOperations.openTrove(
      etherAddress,
      ETHColl,
      maxFee,
      DCHFAmount,
      signer.address,
      signer.address,
      { value: ETHColl }
    );

    const txReceipt = await tx.wait();

    console.log(txReceipt);
  }
});
