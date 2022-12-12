// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract LevelUpRules {
    struct Rule {
        string levelName;
        uint256 amountToUpgrade;
        uint8 pointEarnRatio;
        uint8 pointConsumeRatio;
    }

    uint256 ruleSize;
    mapping(uint256 => Rule) rules;

    modifier ruleExist(uint256 levelId) {
        require(levelId < ruleSize, "Rule Not Exist");

        _;
    }

    function _setUpRules(
        string[] calldata levelNames,
        uint256[] calldata amounts,
        uint8[] calldata pointEarnRatios,
        uint8[] calldata pointConsumeRatios
    ) internal {
        ruleSize = levelNames.length;
        for (uint256 i = 0; i < ruleSize; ++i) {
            rules[i] = Rule({
                levelName: levelNames[i],
                amountToUpgrade: amounts[i],
                pointEarnRatio: pointEarnRatios[i],
                pointConsumeRatio: pointConsumeRatios[i]
            });
        }
    }

    function _clearRules() internal {
        for (uint256 i = 0; i < ruleSize; ++i) {
            delete rules[i];
        }

        ruleSize = 0;
    }

    function _getRuleOfLevel(uint256 levelId) internal view ruleExist(levelId) returns (Rule memory) {
        return rules[levelId];
    }
}
