// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Point is ERC20, Ownable {
    constructor(string memory name, string memory symbol, uint256 initSupply) ERC20(name, symbol) {
        _mint(msg.sender, initSupply);
    }

    // why set to 4 ?
    // 1. 客户端显示的金额为 元，系统存储的是 分
    // 2. 积分比例是百分比，要存成整数，所以先乘 100
    // 3. 1 和 2 的结果相乘，是 10000，所以这边设置为 4
    function decimals() public pure override returns (uint8) {
        return 4;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function consume(address to, uint256 amount) public onlyOwner {
        _burn(to, amount);
    }
}