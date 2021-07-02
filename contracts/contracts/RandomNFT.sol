pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RandomNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;

    constructor() ERC721("RandomNFT", "RAND") public {
        tokenId.increment();
    }

    function award(address winner) external onlyOwner {
        _safeMint(winner, tokenId.current());

        tokenId.increment();
    }

    function getCurrentTokenId() external view returns (uint256) {
        return tokenId.current();
    }
}
