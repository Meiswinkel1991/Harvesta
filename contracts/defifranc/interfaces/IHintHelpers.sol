// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IHintHelpers {
    struct LocalRedemptionVars {
        address _asset;
        uint256 _DCHFamount;
        uint256 _pricel;
        uint256 _maxIterations;
    }

    event SortedTrovesAddressChanged(address _sortedTrovesAddress);
    event TroveManagerAddressChanged(address _troveManagerAddress);

    function getRedemptionHints(
        address _asset,
        uint256 _DCHFamount,
        uint256 _price,
        uint256 _maxIterations
    )
        external
        view
        returns (
            address firstRedemptionHint,
            uint256 partialRedemptionHintNICR,
            uint256 truncatedDCHFamount
        );

    function getApproxHint(
        address _asset,
        uint256 _CR,
        uint256 _numTrials,
        uint256 _inputRandomSeed
    )
        external
        view
        returns (
            address hintAddress,
            uint256 diff,
            uint256 latestRandomSeed
        );

    function computeNominalCR(uint256 _coll, uint256 _debt)
        external
        pure
        returns (uint256);
}
