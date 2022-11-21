// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./defifranc/interfaces/ITroveManagerHelpers.sol";
import "./defifranc/interfaces/IBorrowerOperations.sol";
import "./defifranc/interfaces/IDCHFToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error StakingPool__NoAssetInContract();

contract StakingPool {
    struct TroveSetting {
        uint256 minICR;
        uint256 maxICR;
        uint256 targetICR;
    }

    /* ====== DEFIFRANC CONTRACTS ====== */
    ITroveManagerHelpers public troveManagerHelpersContract;
    IBorrowerOperations public borrowerOperationsContract;
    IDCHFToken public DCHFTokenContract;

    /* ====== StateVariables ====== */

    uint256 constant MAX_FEE = 5e16;

    mapping(address => TroveSetting) private troveSettings;

    /* ====== Functions ====== */

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor(
        address _troveManagerHelpersContract,
        address _borrowerOperationsContract,
        address _DCHFTokenAddress
    ) {
        troveManagerHelpersContract = ITroveManagerHelpers(
            _troveManagerHelpersContract
        );

        borrowerOperationsContract = IBorrowerOperations(
            _borrowerOperationsContract
        );

        DCHFTokenContract = IDCHFToken(_DCHFTokenAddress);
    }

    function openNewTrove(
        uint256 _maxICR,
        uint256 _minICR,
        uint256 _targetICR,
        address _asset
    ) public {
        if (_asset != address(0)) {
            uint256 _balance = IERC20(_asset).balanceOf(address(this));
            if (_balance == 0) {
                revert StakingPool__NoAssetInContract();
            }
        }
    }

    /* ====== Internal Functions ====== */

    function _openTroveWithToken() internal {}

    function _opneTroveWithEther(
        uint256 _maxFee,
        uint256 _amountDebt,
        uint256 _collEther,
        address _upperHint,
        address _lowerHint
    ) internal {
        borrowerOperationsContract.openTrove{value: _collEther}(
            address(0),
            _collEther,
            _maxFee,
            _amountDebt,
            _upperHint,
            _lowerHint
        );
    }

    function _sendDCHFTokensToYieldPool(address _yieldPoolAddress) internal {
        uint256 _balanceDCHF = DCHFTokenContract.balanceOf(address(this));

        DCHFTokenContract.transfer(_yieldPoolAddress, _balanceDCHF);
    }

    /* ====== View / Pure Functions ====== */

    function hasActiveTrove(address _asset) public view returns (bool) {
        return troveManagerHelpersContract.isTroveActive(_asset, address(this));
    }

    function getTroveSettings(address _asset)
        public
        view
        returns (TroveSetting memory)
    {
        return troveSettings[_asset];
    }
}
