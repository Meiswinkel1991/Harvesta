// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./YieldPool.sol";

contract YieldPoolFactory {
    /* ====== State Variables ====== */
    address private implementationContract;

    address[] private deployedYieldPools;

    /* ====== Events ====== */
    event NewYieldPoolDeployed(address yieldPoolAddress);

    /* ====== Functions ====== */

    constructor(address _implementationContract) {
        implementationContract = _implementationContract;
    }

    function deployNewYieldPool(
        address _asset,
        address _yieldManager,
        address _stakingPool
    ) external {
        address payable newContract = payable(
            address(Clones.clone(implementationContract))
        );

        YieldPool(newContract).initialize(_asset, _yieldManager, _stakingPool);

        emit NewYieldPoolDeployed(newContract);
    }

    /* ====== View / Pure Functions ====== */

    function getLastDeployedYieldPool() external view returns (address) {
        return deployedYieldPools[deployedYieldPools.length - 1];
    }

    function getAllYieldPools() external view returns (address[] memory) {
        return deployedYieldPools;
    }

    function getImplementationContract() external view returns (address) {
        return implementationContract;
    }
}
