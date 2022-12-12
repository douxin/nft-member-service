// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Pausable is Ownable {
    bool private isPaused;

    modifier unPause() {
        require(!isPaused, "Merchant Paused");
        _;
    }

    function pauseMerchant() public onlyOwner unPause {
        isPaused = true;
    }

    function unPauseMerchant() public onlyOwner {
        isPaused = false;
    }
}