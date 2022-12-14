// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IPromotion {
    function whenToStart() external returns (uint256);
    function whenToEnd() external returns (uint256);
    function isComplete(address to_) external view returns (bool);
    function rewardAmount(address to) external returns (uint256);
}