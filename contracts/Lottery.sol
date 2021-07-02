pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@iexec/solidity/contracts/ERC1154/IERC1154.sol";
import "@iexec/solidity/contracts/ERC2362/IERC2362.sol";
import "@iexec/doracle/contracts/IexecDoracle.sol";
import "./RandomNFT.sol";

contract Lottery is Ownable {
    enum LotteryState {
        OPEN,
        WAITING_RESULT,
        CLOSE
    }

    RandomNFT public randomNFT;
    LotteryState lotteryState;
    address[] public players;
    mapping(address => uint256) private lastPlayed;

    constructor(RandomNFT _randomNFT) public {
        require(_randomNFT != RandomNFT(0), "RandomNFT cannot be null");
        randomNFT = _randomNFT;
        lotteryState = LotteryState.CLOSE;
    }

    function openLottery() external onlyOwner {
        require(lotteryState == LotteryState.CLOSE);
        lotteryState = LotteryState.OPEN;
        players = new address[](0);
    }

    function participate() external {
        require(lotteryState == LotteryState.OPEN);
        require(lastPlayed[msg.sender] != randomNFT.getCurrentTokenId());

        lastPlayed[msg.sender] = randomNFT.getCurrentTokenId();
        players.push(msg.sender);
    }

    function drawWinner() external onlyOwner {
        require(lotteryState == LotteryState.OPEN);
        require(players.length > 1);

        lotteryState = LotteryState.WAITING_RESULT;
        //TODO ask oracle
    }
}
