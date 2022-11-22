// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

error YieldPool___NotManagerContract();

contract YieldPool is Initializable {
    /* ====== State Variables ====== */
    address private underlyingAsset;

    uint256 private reservePoolSupply;
    uint256 private rewardPoolSupply;
    uint256 private MONTokenSupply;

    address private yieldManagerAddress;
    address private stakingPoolAddress;

    /* ====== Modifiers ====== */

    modifier isManagerContract() {
        if (msg.sender != yieldManagerAddress) {
            revert YieldPool___NotManagerContract();
        }
        _;
    }

    /* ====== Functions ====== */

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _asset,
        address _yieldManagerAddress,
        address _stakingPoolAddress
    ) external initializer {
        yieldManagerAddress = _yieldManagerAddress;
        stakingPoolAddress = _stakingPoolAddress;
        underlyingAsset = _asset;
    }

    function sendDCHFTokensToStakingPool(uint256 _amount)
        external
        isManagerContract
    {}

    /* ====== View / Pure Functions ====== */
}
