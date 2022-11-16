// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./defifranc/interfaces/IBorrowerOperations.sol";
import "./defifranc/interfaces/ITroveManagerHelpers.sol";
import "./defifranc/interfaces/IHintHelpers.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";

error HarvestaStaking__NotEnoughEther();
error HarvestaStaking__TroveIsActive();
error HarvestaStaking__TroveIsNotActive();

contract HarvestaStaking {
    using SafeMath for uint256;

    /* ====== DEFIFRANC Contracts ====== */

    IBorrowerOperations public borrowerOperations;
    IHintHelpers public hintHelpers;
    ITroveManagerHelpers public troveManagerHelper;

    /* ====== State Variables ====== */

    mapping(address => uint256) private totalStakedAssets;

    /* ====== Modifiers ====== */

    modifier hasNoTrove(address _asset) {
        bool _active = troveManagerHelper.isTroveActive(_asset, address(this));
        if (_active) {
            revert HarvestaStaking__TroveIsActive();
        }
        _;
    }

    modifier isTroveActive(address _asset) {
        bool _active = troveManagerHelper.isTroveActive(_asset, address(this));
        if (!_active) {
            revert HarvestaStaking__TroveIsNotActive();
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
        address _troveManagerHelpers
    ) {
        borrowerOperations = IBorrowerOperations(_borrowerOperations);

        hintHelpers = IHintHelpers(_hintHelpers);

        troveManagerHelper = ITroveManagerHelpers(_troveManagerHelpers);
    }

    function openTroveWithHint(
        address _asset,
        uint256 _collEther,
        uint256 _amountDebt
    ) external hasNoTrove(_asset) {}

    function adjustTroveWithHint() external {}

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

    function _openTrove(
        address _asset,
        uint256 _maxFee,
        uint256 _amountDebt,
        uint256 _collEther,
        address _upperHint,
        address _lowerHint
    ) internal {
        if (_collEther > getBalance()) {
            revert HarvestaStaking__NotEnoughEther();
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
    }

    function adjustTrove(
        address _asset,
        uint256 _assetSent,
        uint256 _maxFee,
        uint256 _collWithdrawal,
        uint256 _debtChange,
        bool isDebtIncrease,
        address _upperHint,
        address _lowerHint
    ) internal {}

    function getBalance() internal view returns (uint256) {
        return address(this).balance;
    }
}
