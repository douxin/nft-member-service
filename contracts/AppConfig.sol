// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AppConfig {
    struct Config {
        bool canTransfer;
    }

    Config config;

    modifier transferable {
        require(config.canTransfer, "Cannot transfer");
        _;
    }
}