// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMerchant {
    function setLevelUpRules(
        string[] calldata levelNames,
        uint256[] calldata amountsToUpgrade,
        uint8[] calldata pointEarnRatios,
        uint8[] calldata pointConsumeRatios
    ) external;

    // mint NFT for user, bind user's offchain member id
    function activeMember(bytes32 outMemberId) external;

    // update offchain outMemberId to new one
    function updateOffChainMemberId(bytes32 outMemberId) external;

    function addPointForPayment(address to, bytes32 outTradeNo, uint256 tradeAmount) external;
    function addPointForActivity(address to, address activity) external;

    // invoke this when user pay success
    // it'll add points for member, and update user's member level
    function earnPointFor(address to, uint256 tradeAmount, bytes32 outTradeNo) external;

    // invoke this when consume user's point
    // like use point to exchange goods
    function consumePointOf(address from, uint256 tradeAmount, bytes32 outTradeNo) external;

    // check if tradeNo is recorded on chain
    function isTradeExist(bytes32 outTradeNo) external view returns (bool);

    function isPromotionActive(address promotion) external view returns (bool);

    function activePromotion(address promotion) external;
}
