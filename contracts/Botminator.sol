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

    // Mumbai 
    address private constant LINK = 0x70d1F773A9f81C852087B77F6Ae6d3032B02D2AB;
    address private constant AAVE = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant UNI = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant USDC = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;

    // GET CONTRACT BALANCE
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }



    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function Hedger(address tokenIn, address tokenOut, uint256 numberOftokens) private {


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


    // function botArb(address[2] calldata factory, address[2] calldata tokens, uint amountBorrow) external view {

    //      // Assign dummy token change if needed
    //     address dummyToken;
    //     if (tokens[0] != LINK && tokens[1] != LINK ) {
    //         dummyToken = LINK;
    //     } else if (
    //         tokens[0] != AAVE && tokens[1] != AAVE
    //     ) {
    //         dummyToken = AAVE;
    //     } else if (
    //         tokens[0] != UNI && tokens[1] != UNI 
    //     ) {
    //         dummyToken = UNI;
    //     } else {
    //         dummyToken = USDC;
    //     }

    //     // Get Factory pair address for combined tokens
    //     address pair = IUniswapV2Factory(factory[0]).getPair(
    //         tokens[0],
    //         dummyToken
    //     );

    //     require(pair != address(0), "No Pool");


    //     address token0 = IUniswapV2Pair(pair).token0();
    //     address token1 = IUniswapV2Pair(pair).token1();
    //     uint256 amount0Out = tokens[0] == token0 ? amountBorrow : 0;
    //     uint256 amount1Out = tokens[0] == token1 ? amountBorrow : 0;

    //     bytes memory data = abi.encode(tokens[0], amountBorrow, msg.sender);


    // }




}