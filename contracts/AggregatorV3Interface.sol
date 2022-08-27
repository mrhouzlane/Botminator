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
        priceFeedDAI= AggregatorV3Interface(0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9); // Mainnet
        priceFeedSAND = AggregatorV3Interface(0x35E3f7E558C04cE7eEE1629258EcbbA03B36Ec56); // Mainnet
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
