// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./defifranc/interfaces/IBorrowerOperations.sol";
import "./defifranc/interfaces/ITroveManagerHelpers.sol";
import "./defifranc/interfaces/IHintHelpers.sol";
import "./defifranc/interfaces/IDCHFToken.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

error HarvestaStakingPool__NotEnoughEther();
error HarvestaStakingPool__TroveIsActive();
error HarvestaStakingPool__TroveIsNotActive();
error HarvestaStakingPool__SenderIsNotYieldManager();

contract HarvestaStakingPool {
    using SafeMath for uint256;

    /* ====== DEFIFRANC Contracts ====== */

    IBorrowerOperations public borrowerOperations;
    IHintHelpers public hintHelpers;
    ITroveManagerHelpers public troveManagerHelper;
    IDCHFToken public DCHFToken;

    /* ====== State Variables ====== */

    address private yieldManagerAddress;

    mapping(address => uint256) private totalStakedAssets;

    /* ====== Modifiers ====== */

    modifier hasNoTrove(address _asset) {
        bool _active = troveManagerHelper.isTroveActive(_asset, address(this));
        if (_active) {
            revert HarvestaStakingPool__TroveIsActive();
        }
        _;
    }

    modifier isTroveActive(address _asset) {
        bool _active = troveManagerHelper.isTroveActive(_asset, address(this));
        if (!_active) {
            revert HarvestaStakingPool__TroveIsNotActive();
        }
        _;
    }

    modifier isYieldManager() {
        if (msg.sender != yieldManagerAddress) {
            revert HarvestaStakingPool__SenderIsNotYieldManager();
        }
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor(
        address _borrowerOperations,
        address _hintHelpers,
        address _troveManagerHelpers,
        address _DCHFTokenAddress
    ) {
        borrowerOperations = IBorrowerOperations(_borrowerOperations);

        hintHelpers = IHintHelpers(_hintHelpers);

        troveManagerHelper = ITroveManagerHelpers(_troveManagerHelpers);

        DCHFToken = IDCHFToken(_DCHFTokenAddress);
    }

    function openTroveWithHint(
        address _asset,
        uint256 _collEther,
        uint256 _amountDebt
    ) external hasNoTrove(_asset) {}

    function openTrove(
        address _asset,
        uint256 _collEther,
        uint256 _amountDebt
    ) external hasNoTrove(_asset) {
        uint256 _maxFee = 5e16;

        _openTrove(
            _asset,
            _maxFee,
            _amountDebt,
            _collEther,
            address(this),
            address(this)
        );
    }

    /* ====== Internal Functions ====== */

    function _openTrove(
        address _asset,
        uint256 _maxFee,
        uint256 _amountDebt,
        uint256 _collEther,
        address _upperHint,
        address _lowerHint
    ) internal {
        if (_collEther > getBalance()) {
            revert HarvestaStakingPool__NotEnoughEther();
        }
        if (_asset == address(0)) {
            borrowerOperations.openTrove{value: _collEther}(
                _asset,
                _collEther,
                _maxFee,
                _amountDebt,
                _upperHint,
                _lowerHint
            );
        }

        uint256 _balanceDCHF = DCHFToken.balanceOf(address(this));

        DCHFToken.transfer(yieldManagerAddress, _balanceDCHF);
    }

    /* ====== Pure / View Functions ====== */

    function getBalance() internal view returns (uint256) {
        return address(this).balance;
    }
}
