pragma solidity ^0.8.14;

interface IDeposit {
    function receivedERC20(address _asset, uint256 _amount) external;
}
