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
    function getPriceRate(AggregatorV3Interface priceFeed, uint _amount) public view returns (uint) {
        (, int price,,,) = priceFeed.latestRoundData();
        uint adjust_price = uint(price) * 1e10;
        uint usd = _amount * 1e18;
        uint rate = (usd * 1e18) / adjust_price;
        return rate;
    }
    
    // example for 50$ : 
    // usd = 50 * (10**18) 
    // sand = 927900000000000000
    // result= usd / sand 
    // print(result) 
    // 





}
