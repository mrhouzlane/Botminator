// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


// ----------- SECURITY MEASURE TO PROTECT AGAINST SANDWICH ATTACKS : PRICE ORACLE WITH CHAINLINK -----------------------//

contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeedSAND;
    AggregatorV3Interface internal priceFeedUSDT;

    /**
     * Network: Polygon
     * Aggregator: 
     * Address: 
     */
    constructor() {
        priceFeedSAND = AggregatorV3Interface(0x3D49406EDd4D52Fb7FFd25485f32E073b529C924); //SAND/USD
        priceFeedUSDT = AggregatorV3Interface(0x0A6513e40db6EB1b165753AD52E80663aeA50545); // USDT/USD
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
