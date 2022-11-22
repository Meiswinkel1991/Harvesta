// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./defifranc/interfaces/IStabilityPool.sol";
import "./defifranc/interfaces/IStabilityPoolManager.sol";
import "./defifranc/interfaces/IDCHFToken.sol";
import "./defifranc/interfaces/IPriceFeed.sol";
import "./defifranc/interfaces/IMONStaking.sol";
import "./StakingPool.sol";

error HarvestaYieldManager__AmountExceedDepositedAmount();

contract HarvestaYieldManager {
    /* ====== DEFIFRANC CONTRACTS ====== */
    IDCHFToken public DCHFToken;
    IPriceFeed public priceFeed;
    IStabilityPoolManager public stabilityPoolManager;

    /* ====== State Variables ====== */

    /* ====== Events ====== */

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor(
        address _DCHFTokenAddress,
        address _stabilityPoolManagerAddress,
        address _priceFeedAddress
    ) {
        DCHFToken = IDCHFToken(_DCHFTokenAddress);
        stabilityPoolManager = IStabilityPoolManager(
            _stabilityPoolManagerAddress
        );

        priceFeed = IPriceFeed(_priceFeedAddress);
    }

    /* ====== Main Functions ====== */

    /* ====== Internal Functions ====== */

    /* ====== View / Pure Functions ====== */

    function fetchAssetPrice(address _asset) public view returns (uint256) {
        uint256 _price = priceFeed.getDirectPrice(_asset);

        return _price;
    }

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
