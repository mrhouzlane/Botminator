// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7; //fixed solidity version 

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./safeTransfer.sol";
import "./IUniswapV2.sol";
import "./AggregatorV3Interface.sol";

//@notice  Botminator is a vault that will HedgeRisk on UniSwap/QuickSwap
contract Botminator is Ownable, PriceConsumerV3{

    using SafeTransfer for IERC20;

    address router= 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // on Polygon for Uniswap and Quickswap


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function HedgingRisk(address tokenIn, address tokenOut, uint256 numberOftokens, uint256 amountOutMin, uint256 newAmountOutMin) private {


        // getting liquidity from illiquid market : swapping USD for token of your choice on QuickSwap 
        // USDC --> AAVE
        uint amountIn = numberOftokens * 10 ** 18; 
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(tokenIn).approve(router, amountIn), 'failed'); //gives the router allowance on amountIn on the input token.
		address[] memory tokens = new address[](2);
		tokens[0] = tokenIn;
		tokens[1] = tokenOut;
		uint maxTimeToSwap = block.timestamp + 300;
		uint[] memory amounts = IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, tokens, address(this), maxTimeToSwap);


        // selling in liquid market : hedging by selling same token bought on more liquid market UNISWAP 
        // AAVE --> USDC 

        uint priceFeedPair = uint(getLatestPrice());  //using chainlink oracle to query to price as time t 
        uint newAmountIn = priceFeedPair * amounts[0];
        require(IERC20(tokenOut).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(tokenIn).approve(router, newAmountIn), 'failed'); //gives the router allowance on amountOut on the NEW input token.
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = tokenOut; 
        reverseTokens[1] = tokenIn;
        uint[] memory newAmounts = IUniswapV2Router02(router).swapExactTokensForTokens(newAmountIn, newAmountOutMin, reverseTokens, address(this), maxTimeToSwap);
        uint amountResult = priceFeedPair * newAmounts[0];
        require((amountResult > newAmountIn) , "Loosing arbitrage");


    }


}