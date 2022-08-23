// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7; //fixed solidity version 

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./safeTransfer.sol";
import "./IUniswapV2.sol";
import "./AggregatorV3Interface.sol";

//@notice  Botminator is a vault that will HedgeRisk on UniSwap/QuickSwap
contract botminatorVault is Ownable, PriceConsumerV3{

    using SafeTransfer for IERC20;

    IUniswapV2Router02 dex;  
    address USDTAddress = 0x509Ee0d083DdF8AC028f2a56731412edD63223B9; //Goerli
    address LINKAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB; //Goerli

    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D GOERLI
    constructor(address _router) {
        dex = IUniswapV2Router02(_router);
    }
    
    address router= 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // on Polygon for Uniswap and Quickswap

    // GET CONTRACT BALANCE
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }



    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function Hedger(uint256 amountIn) private {


        // USDT --> LINK:
        //Sending USDT to the vault and approving 
        require(IERC20(USDTAddress).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(USDTAddress).approve(router, amountIn), 'failed');

        //Swapping 
		address[] memory tokens = new address[](2);
		tokens[0] = USDTAddress;
		tokens[1] = LINKAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin = dex.getAmountsOut(amountIn, tokens)[1]; //AmountOutMin of LINK TOKEN
		uint amounts = dex.swapExactTokensForTokens(amountIn, amountOutMin, tokens, address(this), maxTimeToSwap)[1]; //Nbr of token LINK Swapped

        require(amounts > 0, "Transaction aborted");


        //Reverse Swap : LINK --> USDT 
        uint priceFeedPair = uint(getLatestPrice());  // Price of LINK Token 
        uint newAmountInDOLLAR = priceFeedPair * amounts; // Nbr of tokens of LINK * Price of LINK = $ 
        require(IERC20(LINKAddress).transferFrom(msg.sender, address(this), newAmountInDOLLAR), 'failed');
        require(IERC20(LINKAddress).approve(router, amounts), 'failed'); // Allowance of LINK 
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = LINKAddress; 
        reverseTokens[1] = USDTAddress;
        uint amountOutMin2 = dex.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of USDT Token
        dex.swapExactTokensForTokens(amounts, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

        // Arbitrage or not ?
        uint newUSDTBalance = IERC20(USDTAddress).balanceOf(address(this));
        require(newUSDTBalance >= amountIn, "arbitrage inexistant");

    }

}