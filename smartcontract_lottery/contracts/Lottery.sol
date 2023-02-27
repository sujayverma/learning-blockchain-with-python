// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Lottery is VRFV2WrapperConsumerBase, Ownable {
    address payable[] public players;
    address payable public recentWinner; // Stores recent winner address.
    uint256 public recentRandomness;
    uint256 public usdEntryFee;
    bytes32 public keyHash;
    uint32 public callbackGasLimit;
    uint16 public requestConfirmations;
    uint32 public numWords;
    address s_owner;
    AggregatorV3Interface public priceFeeds;
    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    // event RequestSent(uint256 requestId, uint32 numWords);
    // event RequestFulfilled(
    //     uint256 requestId,
    //     uint256[] randomWords,
    //     uint256 payment
    // );

    // struct RequestStatus {
    //     uint256 paid; // amount paid in link
    //     bool fulfilled; // whether the request has been successfully fulfilled
    //     uint256[] randomWords;
    // }
    // mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint256[] public requestWords;
    address public linkAddress;
    address public wrapperAddress;
    // uint32 callbackGasLimit = 100000;
    // uint16 requestConfirmations = 3;
    // uint32 numWords = 2;
    // Enum has following values in order.
    // 0
    // 1
    // 2
    LOTTERY_STATE public lottery_state;

    // After public keyword we can add inherited contract constructor.
    constructor(
        address _priceFeed,
        address _linkAddress,
        address _wrapperAddress
    ) public VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress) {
        usdEntryFee = 50 * (10**18);
        priceFeeds = AggregatorV3Interface(_priceFeed);
        lottery_state = LOTTERY_STATE.CLOSED; // Lottery in closed state.
        linkAddress = _linkAddress;
        wrapperAddress = _wrapperAddress;
    }

    function enter() public payable {
        require(lottery_state == LOTTERY_STATE.OPEN);
        require(msg.value >= getEntranceFee(), "Not Enough Ether!");
        players.push(payable(msg.sender)); // For payable array one needs to push a payable converted value.
    }

    function getEntranceFee() public view returns (uint256) {
        (, int256 price, , , ) = priceFeeds.latestRoundData();
        uint256 adjustedPrice = uint256(price) * (10**10); // Converting it into 18 decimal points to wei. The price is at 8 deciaml from the address.
        //$50, $2000 = ETH,  $2000/ETH
        //50/2000 but solidity doesn't support decimals.
        uint256 costToEnter = (usdEntryFee * 10**18) / adjustedPrice;
        return costToEnter;
    }

    // This function will be called only by admin. So, it need to be onlyOwner
    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't Start a new lottery yet."
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public {
        require(lottery_state == LOTTERY_STATE.OPEN);
        // uint256(
        //     keccak256(
        //         abi.encodePacked(
        //             nonce, // nonce is predictable. (aka: also known as, transaction number)
        //             msg.sender, // msg.sender is predictable.
        //             block.difficulty, // can actually be manipultated by miners!
        //             block.timestamp // timestamps can be predictable.
        //         )
        //     )
        // ) % players.length;

        // We will use Chainlink VRF Provides Verifiable Randomness for actual random number.
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        uint256 requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "You aren't there yet!"
        );
        requestWords = _randomWords;
        require(requestWords.length > 0, "Random not founnd");

        recentRandomness = requestWords[requestWords.length - 1];
        uint256 indexOfWinner = recentRandomness % players.length;
        recentWinner = players[indexOfWinner];
        recentWinner.transfer(address(this).balance);

        //reset
        players = new address payable[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
    }
}
