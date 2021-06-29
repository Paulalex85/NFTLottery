pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RandomNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address owner;

    constructor() ERC721("RandomNFT", "RAN") {
        owner = address(msg.sender);
    }

    function setOwner(address newOwner) {
        require(msg.sender == owner);
        owner = newOwner;
    }

    function award(address winner) public returns (uint256) {
        require(msg.sender == owner);
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(winner, newItemId);

        return newItemId;
    }
}
