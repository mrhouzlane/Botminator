// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


// ----------- SECURITY MEASURE TO PROTECT AGAINST SANDWICH ATTACKS : PRICE ORACLE WITH CHAINLINK -----------------------//

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeedSAND;
    AggregatorV3Interface internal priceFeedUSDT;

    /**
     * Network: Mumbai
     * Aggregator: 2 Paris 
     * Address: 
     */
    constructor() {
        priceFeedSAND = AggregatorV3Interface(0x9dd18534b8f456557d11B9DDB14dA89b2e52e308); //SAND/USD
        priceFeedUSDT = AggregatorV3Interface(0x92C09849638959196E976289418e5973CC96d645); // USDT/USD
    }


    /**
     * Returns the latest price
     */
    function getLatestPrice(AggregatorV3Interface _priceFeed) public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = _priceFeed.latestRoundData();
        return price / 1e8; // 
    }
}
