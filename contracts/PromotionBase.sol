// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interface/IPromotion.sol";

abstract contract PromotionBase is IPromotion {

    address immutable merchant;
    uint256 immutable startAt;
    uint256 immutable endAt;
    uint256 rewardPointAmount;
    mapping (address => bool) private _isComplete;

    constructor(uint256 startAt_, uint256 endAt_) {
        merchant = msg.sender;
        startAt = startAt_;
        endAt = endAt_;
    }

    function setRewardTo(uint256 amount_) public virtual {
        rewardPointAmount = amount_;
    }

    function whenToStart() public virtual view returns (uint256) {
        return startAt;
    }

    function whenToEnd() public virtual view returns (uint256) {
        return endAt;
    }

    function isComplete(address to_) public view returns (bool) {
        return _isComplete[to_];
    }

    function rewardAmount(address to_) public virtual view returns (uint256) {
        require(isComplete(to_), "Not complete promotion");
        return rewardPointAmount;
    }
}