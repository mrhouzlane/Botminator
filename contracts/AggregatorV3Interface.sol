// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


// ----------- SECURITY MEASURE TO PROTECT AGAINST SANDWICH ATTACKS : PRICE ORACLE WITH CHAINLINK -----------------------//

contract PriceConsumerV3 {

    AggregatorV3Interface public priceFeedDAI;
    AggregatorV3Interface public priceFeedSAND;

    /**
     * Network: Polygon
     * Aggregator: 
     * Address: 
     */
    constructor() {
        priceFeedDAI= AggregatorV3Interface(0x0FCAa9c899EC5A91eBc3D5Dd869De833b06fB046); // MUMBAI more volatile
        priceFeedSAND = AggregatorV3Interface(0x9dd18534b8f456557d11B9DDB14dA89b2e52e308); // MUMBAI less volatile
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
        return price; // 
    }
}
