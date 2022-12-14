// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interface/IMerchant.sol";
import "./interface/IPromotion.sol";
import "./Point.sol";
import "./Member.sol";
import "./LevelUpRules.sol";
import "./Pausable.sol";

contract Merchant is Ownable, LevelUpRules, IMerchant, Pausable {
    Point private _point;
    Member private _member;

    struct MerchantInfo {
        string name;
        string symbol;
    }

    MerchantInfo private merchant;

    using Counters for Counters.Counter;
    Counters.Counter memberId;

    enum OrderType {
        IncPoint,
        DecPoint
    }

    struct MemberInfo {
        uint256 tokenId;
        uint256 leftAmountToUpgrade;
        uint8 level;
        bytes32 outMemberId;
    }

    event PointAmountUpdate(
        address indexed user,
        OrderType orderType,
        uint256 tradeAmount,
        bytes32 outTradeNo,
        uint256 latestPointAmount,
        uint256 updatedPointAmount
    );

    // promotion activities actived by merchant
    mapping(address => bool) private _activedPromotions;

    mapping(bytes32 => bool) private _tradeNos;
    mapping(address => MemberInfo) private _activeMembers;
    mapping(address => bool) actived;

    uint256 immutable pointAmountRewardWhenActiveCard;

    constructor(
        string memory name,
        string memory symbol,
        uint256 activePointAmount,
        uint256 initPointSupply
    ) {
        merchant = MerchantInfo({name: name, symbol: symbol});

        bytes32 salt = keccak256(abi.encode(name, symbol));

        // deploy point contract
        _point = new Point{salt: salt}(name, symbol, initPointSupply);

        // deploy member contract
        _member = new Member{salt: salt}(name, symbol);

        pointAmountRewardWhenActiveCard = activePointAmount;
    }

    function setLevelUpRules(
        string[] calldata levelNames,
        uint256[] calldata consumeAmounts,
        uint8[] calldata pointEarnRatios,
        uint8[] calldata pointConsumeRatios
    ) public onlyOwner {
        _setUpRules(
            levelNames,
            consumeAmounts,
            pointEarnRatios,
            pointConsumeRatios
        );
    }

    function activeMember(bytes32 outMemberId) public {
        require(msg.sender == tx.origin, "Should be EOA");
        require(!actived[msg.sender], "Actived");

        uint256 id = memberId.current();
        Rule memory rule = _getRuleOfLevel(0);
        _activeMembers[msg.sender] = MemberInfo({
            tokenId: id,
            level: 0,
            leftAmountToUpgrade: rule.amountToUpgrade,
            outMemberId: outMemberId
        });
        actived[msg.sender] = false;
        _member.mint(msg.sender, id);

        if (pointAmountRewardWhenActiveCard > 0) {
            _point.mint(msg.sender, pointAmountRewardWhenActiveCard);
        }
    }

    function updateOffChainMemberId(bytes32 outMemberId) public {
        require(actived[msg.sender], "Should Actived");
        _activeMembers[msg.sender].outMemberId = outMemberId;
    }

    // add point, update user's point amount and member level
    function earnPointFor(
        address to,
        uint256 tradeAmount,
        bytes32 outTradeNo
    ) public onlyOwner {
        _addPointFor(to, tradeAmount, outTradeNo);
        _updateMemberLevel(to, tradeAmount);
    }

    // consume point, update user's point amount
    function consumePointOf(
        address to,
        uint256 tradeAmount,
        bytes32 outTradeNo
    ) public unPause {
        uint256 pointBefore = _point.balanceOf(to);

        Rule memory rule = ruleOf(to);
        uint8 pointConsumeRatio = rule.pointConsumeRatio;
        uint256 canConsumePoint = tradeAmount * pointConsumeRatio;

        require(pointBefore >= canConsumePoint, "insufficient point amount");

        _point.consume(to, canConsumePoint);
        uint256 pointAfter;
        unchecked {
            pointAfter = pointBefore - canConsumePoint;
        }

        emit PointAmountUpdate(
            to,
            OrderType.DecPoint,
            tradeAmount,
            outTradeNo,
            pointBefore,
            pointAfter
        );
    }

    function getMerchantInfo() public view returns (MerchantInfo memory) {
        return merchant;
    }

    function isPromotionActive(address promotion) public view returns (bool) {
        return _activedPromotions[promotion];
    }

    function _addPointFor(
        address to,
        uint256 tradeAmount,
        bytes32 outTradeNo
    ) private unPause {
        Rule memory rule = ruleOf(to);
        uint8 ratio = rule.pointEarnRatio;
        uint256 pointAmount = tradeAmount / ratio;
        require(pointAmount > 0, "Low amount");

        uint256 pointBefore = _point.balanceOf(to);
        _point.mint(to, pointAmount);

        uint256 pointAfter;
        unchecked {
            pointAfter = pointBefore + pointAmount;
        }

        emit PointAmountUpdate(
            to,
            OrderType.IncPoint,
            tradeAmount,
            outTradeNo,
            pointBefore,
            pointAfter
        );
    }

    function _updateMemberLevel(address user, uint256 tradeAmount) private {
        uint256 leftAmount = _activeMembers[user].leftAmountToUpgrade;
        uint256 updatedAmount;
        if (tradeAmount >= leftAmount) {
            // upgrade to next level
            uint8 nextLevel;
            unchecked {
                updatedAmount = tradeAmount - leftAmount;
                nextLevel = _activeMembers[user].level + 1;
            }

            Rule memory rule = _getRuleOfLevel(nextLevel);
            uint256 nextLevelLeftAmount;
            unchecked {
                nextLevelLeftAmount = rule.amountToUpgrade - updatedAmount;
            }

            _activeMembers[user].level = nextLevel;
            _activeMembers[user].leftAmountToUpgrade = nextLevelLeftAmount;
        } else {
            // decrese left amount
            unchecked {
                updatedAmount = leftAmount - tradeAmount;
            }
            _activeMembers[user].leftAmountToUpgrade = updatedAmount;
        }
    }

    function isTradeExist(bytes32 tradeNo) public view returns (bool) {
        return _tradeNos[tradeNo];
    }

    function ruleOf(address user) private view returns (Rule memory rule) {
        uint8 level = _activeMembers[user].level;
        rule = _getRuleOfLevel(level);
    }

    function addPointForPayment(
        address to,
        bytes32 outTradeNo,
        uint256 tradeAmount
    ) external override {}

    function addPointForActivity(
        address to,
        address activity
    ) external override {
        require(isPromotionActive(activity), "Promotion not active");
        uint256 amount = IPromotion(activity).rewardAmount(to);
        _point.mint(to, amount);
    }

    function activePromotion(address promotion) public onlyOwner {
        require(!_activedPromotions[promotion], "Promotion Actived");
        _activedPromotions[promotion] = true;
    }
}
