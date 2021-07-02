pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@iexec/solidity/contracts/ERC1154/IERC1154.sol";
import "@iexec/doracle/contracts/IexecDoracle.sol";
import "./RandomNFT.sol";

contract Lottery is Ownable, IOracleConsumer, IexecDoracle {
    struct LotteryResults {
        bytes32 oracleCallID;
        uint256 value;
        string details;
    }

    mapping(bytes32 => LotteryResults) public oracleResults;
    bytes32 currentOracleResultId;

    enum LotteryState {
        OPEN,
        WAITING_RESULT,
        CLOSE
    }

    RandomNFT public randomNFT;
    LotteryState lotteryState;
    address[] public players;
    mapping(address => uint256) private lastPlayed;

    constructor(RandomNFT _randomNFT, address _iexecHubAddr)
        public
        IexecDoracle(_iexecHubAddr)
    {
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
        uint256 currentId = randomNFT.getCurrentTokenId();
        currentOracleResultId = keccak256(
            abi.encodePacked("lottery", currentId)
        );
        //TODO ask oracle
    }

    function resolveLottery() external {
        require(lotteryState == LotteryState.WAITING_RESULT);
        require(
            oracleResults[currentOracleResultId].oracleCallID != bytes32(0)
        );

        lotteryState = LotteryState.CLOSE;
        randomNFT.award(players[oracleResults[currentOracleResultId].value]);
    }

    function updateEnv(
        address _authorizedApp,
        address _authorizedDataset,
        address _authorizedWorkerpool,
        bytes32 _requiredtag,
        uint256 _requiredtrust
    ) public onlyOwner {
        _iexecDoracleUpdateSettings(
            _authorizedApp,
            _authorizedDataset,
            _authorizedWorkerpool,
            _requiredtag,
            _requiredtrust
        );
    }

    function receiveResult(bytes32 _callID, bytes calldata) external override {
        // Parse results
        (string memory details, uint256 value) = abi.decode(
            _iexecDoracleGetVerifiedResult(_callID),
            (string, uint256)
        );

        // Process results
        bytes32 id = keccak256(bytes(details));
        oracleResults[id].oracleCallID = _callID;
        oracleResults[id].value = value;
        oracleResults[id].details = details;
    }
}
