// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./defifranc/interfaces/IStabilityPool.sol";
import "./defifranc/interfaces/IStabilityPoolManager.sol";
import "./defifranc/interfaces/IDCHFToken.sol";
import "./defifranc/interfaces/IPriceFeed.sol";
import "./defifranc/interfaces/IMONStaking.sol";
import "./HarvestaStakingPool.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

error HarvestaYieldManager__AmountExceedDepositedAmount();

contract HarvestaYieldManager {
    using SafeCast for int;
    using SafeCast for uint256;
    using SafeMath for uint256;

    /* ====== DEFIFRANC CONTRACTS ====== */
    IDCHFToken public DCHFToken;
    IPriceFeed public priceFeed;
    IStabilityPoolManager public stabilityPoolManager;

    /* ====== State Variables ====== */
    uint256 private reservePool;
    uint256 private rewardPool;

    mapping(address => IStabilityPool) private stabilityPoolAddresses;

    uint256 private checkPoint;
    uint256 private executionDuration;

    /* ====== Events ====== */
    event UpdateDCHFDeposit(uint256 totalDeposit, uint256 amountSent);

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

        //implement the priceFeed and stabilityPool for Ether
        address zeroAddress = address(0);
        stabilityPoolAddresses[zeroAddress] = stabilityPoolManager
            .getAssetStabilityPool(address(0));
    }

    /* ====== Main Functions ====== */

    /* ====== Internal Functions ====== */

    function _checkForTroveAdjustment() internal view returns (bool) {
        uint256 _price = fetchAssetPrice(address(0));
    }

    function _stakeMONTokens(uint256 _amount) internal {}

    function _unstakeMONTokens(uint256 _amount) internal {}

    function _transferAvailableTokensToStabilityPool(address _asset) public {
        uint256 _balance = DCHFToken.balanceOf(address(this));

        IStabilityPool pool = stabilityPoolAddresses[_asset];

        pool.provideToSP(_balance);
    }

    function withdrawTokensFromStabilityPool(address _asset, uint256 _amount)
        internal
    {
        uint256 _depositedTokens = stabilityPoolAddresses[_asset]
            .getCompoundedDCHFDeposit(address(this));

        if (_amount > _depositedTokens) {
            revert HarvestaYieldManager__AmountExceedDepositedAmount();
        }

        stabilityPoolAddresses[_asset].withdrawFromSP(_amount);
    }

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
