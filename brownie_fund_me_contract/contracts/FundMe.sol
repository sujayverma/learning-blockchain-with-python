// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // This will map the address of users who send the fund.
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeeds;

    // Constructor function.
    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeeds = AggregatorV3Interface(_priceFeed);
    }

    // Public payable type function is used for receiving payment.
    function fund() public payable {
        // msg.sender & msg.value is key words in every payable function used retriving sender's address and amount.
        uint256 minimumUSD = 50 * 10**18;
        // Here in solidity requrie is a condition operator function.
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH!"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    // Public function used for returning the mainnet version using interface.
    function getVersion() public view returns (uint256) {
        // Interface useds for getting version. Address used is on test mainnet.
        // AggregatorV3Interface priceFeeds = AggregatorV3Interface(
        //     0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        // );
        return priceFeeds.version();
    }

    // Public function used for returning ETH to USD value.
    function getPrice() public view returns (uint256) {
        // The ETH to USD convertor address can be found here https://docs.chain.link/docs/data-feeds/price-feeds/addresses/.
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        // );
        // This returns ETH to USD price. Blank is used for other components parameters. Like roundId, answer, startedAt, updatedAt, answeredInRound.
        (, int256 answer, , , ) = priceFeeds.latestRoundData();
        // ETH/USD rate in 18 digit
        return uint256(answer * 10000000000); // Value returned 1345.64060562
    }

    // View for displaying the conversion rate with some calculations.
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        // 0.000000136028173514
    }

    function getEntranceFee() public view returns (uint256) {
        //minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / getPrice();
    }

    // Common code for being multiple times in the contract. Kind of works as access modifier.
    //modifier: https://medium.com/coinmonks/solidity-tutorial-all-about-modifiers-a86cf81c14cb
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "You are not the owner of this Contract!! Buzz off!"
        );
        _; // Kind of placeholder for rest of the code.
    }

    // It helps is withdrawing the funded amount by contract owner.
    function withdraw() public payable onlyOwner {
        // Transfer is function which can be called on any address. this here means current contract.
        payable(msg.sender).transfer(address(this).balance);

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
    }
}
