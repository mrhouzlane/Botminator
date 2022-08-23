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

    // GET CONTRACT BALANCE
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }



    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function HedgingRisk(address tokenIn, address tokenOut, uint256 numberOftokens) private {


        // getting liquidity from illiquid market : swapping USD for token of your choice on QuickSwap 
        // Y --> X 
        
        uint amountIn = numberOftokens * 10 ** 18; 
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(tokenIn).approve(router, amountIn), 'failed'); //gives the router allowance on amountIn on the input token.
		address[] memory tokens = new address[](2);
		tokens[0] = tokenIn;
		tokens[1] = tokenOut;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin = IUniswapV2Router02(router).getAmountsOut(amountIn, tokens)[1];
		uint amounts = IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, tokens, address(this), maxTimeToSwap)[1];

        require(amounts > 0, "Transaction aborted");


        // selling in liquid market : hedging by selling same token bought on more liquid market UNISWAP 
        // X --> Y

        uint priceFeedPair = uint(getLatestPrice());  //using chainlink oracle to query to price as time t 
        uint newAmountIn = priceFeedPair * amounts;
        require(IERC20(tokenOut).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(tokenOut).approve(router, newAmountIn), 'failed'); //gives the router allowance on amountOut on the NEW input token.
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = tokenOut; 
        reverseTokens[1] = tokenIn;
        uint newAmountOutMin = IUniswapV2Router02(router).getAmountsOut(amountIn, tokens)[1];
        uint newAmounts = IUniswapV2Router02(router).swapExactTokensForTokens(newAmountIn, newAmountOutMin, reverseTokens, address(this), maxTimeToSwap)[1];

        // Result : 
        require(newAmounts > 0, "Transaction aborted");

    }


    function checkHedgingResult(uint input, uint output) private pure returns (bool){
        return output >= input ;
    }




}