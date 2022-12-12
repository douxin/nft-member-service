// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Member is ERC721, Ownable {
    string private _baseUri;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
    }

    function isMinted(address to) internal view returns (bool) {
        if (balanceOf(to) > 0) {
            return true;
        } else {
            return false;
        }
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        require(!isMinted(to), "Minted");
        _mint(to, tokenId);
    }

    function setBaseUri(string memory uri) public onlyOwner {
        _baseUri = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }
}