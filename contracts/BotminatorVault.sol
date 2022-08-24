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
    address SANDAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB; // Polygon
    address USDTAddress = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; // Polygon

    //0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D GOERLI
    constructor(address _router) {
        dex = IUniswapV2Router02(_router);
    }
    
    address router=0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // on Polygon for Uniswap and Quickswap

    // GET CONTRACT BALANCE
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function Hedger(uint256 amountIn) private {


        // USDT--> SAND         -------- UNISWAP --------- 
        //Sending USDT to the vault and approving 
        uint priceFeed1 = uint(getLatestPrice(priceFeedUSDT));
        uint PriceOracleEntry = priceFeed1 * amountIn;

        require(IERC20(USDTAddress).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(USDTAddress).approve(router, amountIn), 'failed');

        //Swapping 
		address[] memory tokens = new address[](2);
		tokens[0] = USDTAddress;
		tokens[1] = SANDAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin = dex.getAmountsOut(amountIn, tokens)[1]; //AmountOutMin of LINK TOKEN
		uint amounts = dex.swapExactTokensForTokens(amountIn, amountOutMin, tokens, address(this), maxTimeToSwap)[1]; //Nbr of token LINK Swapped

        require(amounts > 0, "Transaction aborted");


        //Reverse Swap : SAND --> USDT       ------ QUICKSWAP ------ 
        //Calcul of new input token based on last price of Output Token :
        uint priceFeed2 = uint(getLatestPrice(priceFeedSAND));
        uint newAmountIn = amounts - ((amountIn * priceFeed1)/priceFeed2);

        //DO SECOND SWAP 
        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(SANDAddress).approve(router, newAmountIn), 'failed'); // Allowance of LINK 
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = USDTAddress;
        uint amountOutMin2 = dex.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of USDT Token
        uint BTCExit = dex.swapExactTokensForTokens(newAmountIn, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

        // Arbitrage or not ?
        //uint newUSDTBalance = IERC20(USDTAddress).balanceOf(address(this));
        uint priceFeedLast = uint(getLatestPrice(priceFeedUSDT));
        uint PriceOracleExit = priceFeedLast * BTCExit; 

        require(PriceOracleEntry <= PriceOracleExit, "Proof of Price Variation not valid ");


    }

}