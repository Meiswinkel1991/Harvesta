// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./defifranc/interfaces/ITroveManagerHelpers.sol";
import "./defifranc/interfaces/IBorrowerOperations.sol";
import "./defifranc/interfaces/IDCHFToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error StakingPool__NoAssetInContract();
error StakingPool__HasActiveTrove();
error StakingPool__AmountIsZero();
error StakingPool__NotAllowedToTransferTokens();
error StakingPool__TransferTokenFailed();

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

    mapping(address => uint256) private totalAssetSupply;
    mapping(address => mapping(address => uint256)) private stakerBalance;

    /* ====== Events ====== */
    event StakeUpdated(
        address asset,
        address staker,
        uint256 newStake,
        uint256 totalStackedAsset
    );

    /* ====== Modifier ====== */

    modifier nonZeroEtherAmount() {
        if (msg.value == 0) {
            revert StakingPool__AmountIsZero();
        }
        _;
    }

    modifier nonZeroAmount(uint256 _amount) {
        if (_amount == 0) {
            revert StakingPool__AmountIsZero();
        }
        _;
    }

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

    function stakeETH() external payable nonZeroEtherAmount {
        uint256 _stakeAmount = msg.value;
        address _zeroAddress = address(0);
        _stakeAsset(_zeroAddress, _stakeAmount, msg.sender);
    }

    function stakeAsset(uint256 _amount, address _asset)
        external
        nonZeroAmount(_amount)
    {
        uint256 _allowance = IERC20(_asset).allowance(
            msg.sender,
            address(this)
        );

        if (_allowance < _amount) {
            revert StakingPool__NotAllowedToTransferTokens();
        }

        bool sent = IERC20(_asset).transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (!sent) {
            revert StakingPool__TransferTokenFailed();
        }

        _stakeAsset(_asset, _amount, msg.sender);
    }

    /**
     * @dev -  opne a new trove if a trove with this asset dont exist
     * @param _asset - the contract address of the token want to use as collateral (ETHER is zero address)
     * @param _minICR - the minimum ICR of the trove
     * @param _maxICR - the maximum ICR of the trove
     * @param _targetICR - the target ICR of the trove when adjusting the trove
     */
    function openNewTrove(
        uint256 _maxICR,
        uint256 _minICR,
        uint256 _targetICR,
        address _asset
    ) public {
        bool active = troveManagerHelpersContract.isTroveActive(
            _asset,
            address(this)
        );

        if (active) {
            revert StakingPool__HasActiveTrove();
        }

        if (_asset != address(0)) {
            uint256 _balance = IERC20(_asset).balanceOf(address(this));
            if (_balance == 0) {
                revert StakingPool__NoAssetInContract();
            }
        } else {
            uint256 _balance = getBalance();

            if (_balance == 0) {
                revert StakingPool__NoAssetInContract();
            }
        }

        troveSettings[_asset] = TroveSetting(_minICR, _maxICR, _targetICR);
    }

    /* ====== Internal Functions ====== */

    function _stakeAsset(
        address _asset,
        uint256 _amount,
        address _staker
    ) internal {
        totalAssetSupply[_asset] += _amount;
        stakerBalance[_asset][_staker] += _amount;

        emit StakeUpdated(
            _asset,
            _staker,
            stakerBalance[_asset][_staker],
            totalAssetSupply[_asset]
        );
    }

    function _openTroveWithToken() internal {}

    function _openTroveWithEther(
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

    function getBalance() internal view returns (uint256) {
        return address(this).balance;
    }
}
