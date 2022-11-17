// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./defifranc/interfaces/IStabilityPool.sol";
import "./defifranc/interfaces/IStabilityPoolManager.sol";
import "./defifranc/interfaces/IDCHFToken.sol";
import "./HarvestaStaking.sol";

contract HarvestaYieldManager {
    /* ====== DEFIFRANC CONTRACTS ====== */
    IDCHFToken public DCHFToken;
    IStabilityPool public stabilityPool;
    IStabilityPoolManager public stabilityPoolManager;

    /* ====== State Variables ====== */
    uint256 private stakerDCHFTokens;

    constructor(address _DCHFTokenAddress, address _stabilityPoolManagerAddress)
    {
        DCHFToken = IDCHFToken(_DCHFTokenAddress);
        stabilityPoolManager = IStabilityPoolManager(
            _stabilityPoolManagerAddress
        );

        stabilityPool = stabilityPoolManager.getAssetStabilityPool(address(0));
    }

    /* ====== Functions ====== */

    /* ====== View / Pure Functions ====== */

    function checkStakingContractICR() public view returns (uint256) {}

    /**
     * TODO:
     *  1. Fetch for the actual asset price via ChainLink PriceFeed
     *  2. Check the current ICR of the stakingContract
     *  3. Adjust the trove, if the ICR out of the range
     *  4. Implement ChainLink Keeper and automate the check
     *  5. Only adjust the trove every 24h or rescue operation
     *  6. Implement a overview of all troves and check for liquidation
     *  7. Automate the liquidate process
     * 8. After Liquidation fill the Emergency Trove with the assets
     * 9. Add the DCHF to the stability pool
     */
}
