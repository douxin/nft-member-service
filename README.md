# NFT as Member Service
Build merchant member service with NFT.

## How to use
参照 `scripts/deploy-merchant.ts` 脚本，修改 `Merchant` 参数

## User Story
### as Merchant
1. 开通会员卡服务，设置消费金额兑换成积分的比例，设置会员级别升级规则
2. 商家可以冻结和解冻会员服务，冻结后各项服务不可用

### as Consumer
1. 在商家开通会员卡
2. 消费可以获得积分，可以使用积分抵扣金额。不同的会员等级，消费金额兑换成积分的比例不同
3. 消费到一定额度，可以升级到下一个会员等级

## 合约结构
- Merchant: 店铺主合约，在此合约内自动创建会员卡、积分，保存升级规则、积分兑换规则等
- Member: 会员卡合约
- Point: 积分合约