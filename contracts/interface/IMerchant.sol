// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMerchant {
    function setLevelUpRules(
        string[] calldata levelNames,
        uint256[] calldata amountsToUpgrade,
        uint8[] calldata pointEarnRatios,
        uint8[] calldata pointConsumeRatios
    ) external;

    function activeMember(bytes32 outMemberId) external;

    function earnPointFor(address to, uint256 tradeAmount, bytes32 outTradeNo) external;

    function consumePointOf(address from, uint256 tradeAmount, bytes32 outTradeNo) external;

    function isTradeExist(bytes32 outTradeNo) external view returns (bool);
}
