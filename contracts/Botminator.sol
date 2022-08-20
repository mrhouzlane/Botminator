// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7; //fixed solidity version 

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./safeTransfer.sol";
import "./IUniswapV2.sol";
import "./AggregatorV3Interface.sol";


contract Botminator is Ownable, PriceConsumerV3{

    using SafeTransfer for IERC20;



    //1. FIRST STEP : 


    ///@notice Funding the contract with X tokens to swap
    function fillContract(address tokenIn) external {
        //address tokenDAI  : 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        uint tokenInPrice = uint(getLatestPrice()); 
        // add oracle to get price feed 
        uint amountIn = 5 * 10 ** tokenInPrice; // We are choosing to swap 5 tokens of token X [maybe add decimals()] !! 
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), 'transferFrom failed.');
    }


    ///@notice swap function to call in the process 
    function swap(address router, address tokenIn, address tokenOut, uint256 numberOftokens, uint256 amountOutMin) private {
        uint amountIn = uint(getLatestPrice()) * numberOftokens; 
		IERC20(tokenIn).approve(router, amountIn);
		address[] memory tokens = new address[](2);
		tokens[0]= tokenIn;
		tokens[1] = tokenOut;
		uint  maxtimeToSwap = block.timestamp + 300;
		IUniswapV2Router02(router).swapExactTokensForTokens(amountIn, amountOutMin, tokens, address(this), maxtimeToSwap);
	}

    function CanTradeIn() public view returns (bool) {}


    ///@notice trade function to buy in a dex(router 1 || 2 ... ) and sell in another dex (router 2 || 3 || 4 ...)
    function trade(address _router1, address _router2, address _token1, address _token2, uint256 amountIn, uint256 amountOutMin) external onlyOwner {
        uint startBalance = IERC20(_token1).balanceOf(address(this));
        uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));
        swap(_router1,_token1, _token2, amountIn, amountOutMin);


        // buy in one router 








        // sell in another router 

    }


// ----------- SECURITY MEASURE TO PROTECT AGAINST SANDWICH ATTACKS : PRICE ORACLE WITH CHAINLINK -----------------------




}