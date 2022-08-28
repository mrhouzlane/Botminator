// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7; //fixed solidity version 

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./safeTransfer.sol";
import "./IUniswapV2.sol";
import "./AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "hardhat/console.sol";

//@notice  Botminator is a vault that will HedgeRisk on UniSwap/QuickSwap
contract botminatorVault is Ownable, PriceConsumerV3{

    using SafeTransfer for IERC20;

    IUniswapV2Router02 Quickswap;
    IUniswapV2Router02 Sushiswap;  
    address PriceConsumerV3Address;

    mapping( uint => uint ) public HedgerRoute1Map ; //mapping between amountIn and amoutOut 
    mapping( uint => uint ) public HedgerRoute2Map ; //mapping between amountIn and amoutOut


    // Dai 
    address DAIAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // Mainnet

    // Sand 
    address SANDAddress = 0x3845badAde8e6dFF049820680d1F14bD3903a5d0; // Mainnet

    address LINKAddress = 0x514910771AF9Ca656af840dff83E8264EcF986CA; // Mainnet

    address routerSushiswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D	; // Sushiswap router on Mainnet
    address routerQuickswap = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D	; // using sushiswap for the moment 

    constructor() {
        Quickswap = IUniswapV2Router02(routerQuickswap);
        Sushiswap = IUniswapV2Router02(routerSushiswap);
    }

    function transferLink() external payable {
        require(msg.value <= 0.1 ether);
        IERC20(LINKAddress).transferFrom(msg.sender, address(this), 2);
    }


    ///@notice getting liquidity from illiquid market and selling in liquid market
    ///@dev amountIn is the amount in dollars that you want to spend 
    function HedgerRoute1(uint256 amountIn) external payable {

        // DAI--> SAND         -------- Sushiswap --------- 
        //Sending DAI to the vault and approving

        //transfer Link token 
        (, int256 answer, , ,  ) = AggregatorV3Interface(priceFeedDAI).latestRoundData();
        uint priceFeed1 = uint(answer);

        // uint priceFeed1 = uint(getLatestPrice(AggregatorV3Interface(0x0A6513e40db6EB1b165753AD52E80663aeA50545)));
        uint amountInTokens = amountIn / priceFeed1;
        // uint PriceOracleEntry = priceFeed1 * amountIn; 

        require(IERC20(DAIAddress).transferFrom(msg.sender, address(this), amountInTokens), 'failed');
        require(IERC20(DAIAddress).approve(routerSushiswap, amountInTokens), 'failed');

		address[] memory tokens = new address[](2);
		tokens[0] = DAIAddress;
		tokens[1] = SANDAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin1 = Sushiswap.getAmountsOut(amountInTokens, tokens)[1]; 

        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = DAIAddress;

        // ------ SWAP CAN START NOW --------------------

		uint amounts = Sushiswap.swapExactTokensForTokens(amountInTokens, amountOutMin1, tokens, address(this), maxTimeToSwap)[1]; 
        require(amounts > 0, "Transaction aborted");

        //Reverse Swap : SAND --> DAI       ------ Quickswap ------ 
        //Calcul of new input token based on last price of Output Token :
        uint priceFeed2 = uint(getLatestPrice(priceFeedSAND));
        uint newAmountIn = amounts - ((amountInTokens * priceFeed1)/priceFeed2);

        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(SANDAddress).approve(routerQuickswap, newAmountIn), 'failed'); // Allowance of LINK 
        uint amountOutMin2 = Quickswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of DAI Token
        Quickswap.swapExactTokensForTokens(newAmountIn, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

    }


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    ///@dev amountIn is the amount in dollars that you want to spend 
    function HedgerRoute2(uint256 amountIn) public {

        // DAI--> SAND         -------- Quickswap --------- 
        //Sending DAI to the vault and approving 
        uint priceFeed1 = uint(getLatestPrice(priceFeedDAI));
        uint amountInTokens = amountIn / priceFeed1;
        // uint PriceOracleEntry = priceFeed1 * amountIn;  

        require(IERC20(DAIAddress).transferFrom(msg.sender, address(this), amountInTokens), 'failed');
        require(IERC20(DAIAddress).approve(routerQuickswap, amountInTokens), 'failed');

        
        address[] memory tokens = new address[](2);
		tokens[0] = DAIAddress;
		tokens[1] = SANDAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin1 = Quickswap.getAmountsOut(amountInTokens, tokens)[1]; 

        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = DAIAddress;

		
        // ------ SWAP CAN START NOW --------------------
		uint amounts = Quickswap.swapExactTokensForTokens(amountInTokens, amountOutMin1, tokens, address(this), maxTimeToSwap)[1]; 
        require(amounts > 0, "Transaction aborted");

        //Reverse Swap : SAND --> DAI       ------ Sushiswap ------ 
        //Calcul of new input token based on last price of Output Token :
        uint priceFeed2 = uint(getLatestPrice(priceFeedSAND));
        uint newAmountIn = amounts - ((amountInTokens * priceFeed1)/priceFeed2);

        //DO SECOND SWAP 
        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(SANDAddress).approve(routerSushiswap, newAmountIn), 'failed'); // Allowance of LINK 
       
        uint amountOutMin2 = Sushiswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of DAI Token
        Sushiswap.swapExactTokensForTokens(newAmountIn, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

    
    }

    function predictSwapOracleRoute1(uint numberOfTokenIn) external returns (bool) {

        // setup of tokens 
        address[] memory tokens = new address[](2);
		tokens[0] = DAIAddress;
		tokens[1] = SANDAddress;
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = DAIAddress;

        // Prediction of expectedOut amount after 2 swaps 
        uint amountOutMin1 = Sushiswap.getAmountsOut(numberOfTokenIn, tokens)[1];  //prediction nbr tokens after 1 swap 
        uint expectedOutMin2 = Quickswap.getAmountsOut(amountOutMin1, reverseTokens)[1]; //prediction nbr tokens after 2nd swap 

        // Oracle use to predict the $ we get at the end of 2 swaps
        uint priceFeed1 = uint(getLatestPrice(priceFeedDAI));
        uint PriceOracleEntry = priceFeed1 * numberOfTokenIn;  
        uint priceFeedLast = uint(getLatestPrice(priceFeedDAI));
        uint expectedPriceOracleExit = priceFeedLast * expectedOutMin2; 
        
        HedgerRoute1Map[PriceOracleEntry] = expectedPriceOracleExit;

        if (PriceOracleEntry < expectedPriceOracleExit){
            return true;
        } 

    }


    function predictSwapOracleRoute2(uint numberOfTokenIn) external returns (bool) {

        // setup of tokens 
        address[] memory tokens = new address[](2);
		tokens[0] = DAIAddress;
		tokens[1] = SANDAddress;
        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = DAIAddress;

        // Prediction of expectedOut amount after 2 swaps 
        uint amountOutMin1 = Quickswap.getAmountsOut(numberOfTokenIn, tokens)[1];  //prediction nbr tokens after 1 swap 
        uint expectedOutMin2 = Sushiswap.getAmountsOut(amountOutMin1, reverseTokens)[1]; //prediction nbr tokens after 2nd swap 

        // Oracle use to predict the $ we get at the end of 2 swaps
        uint priceFeed1 = uint(getLatestPrice(priceFeedDAI));
        uint PriceOracleEntry = priceFeed1 * numberOfTokenIn;  
        uint priceFeedLast = uint(getLatestPrice(priceFeedDAI));
        uint expectedPriceOracleExit = priceFeedLast * expectedOutMin2; 

        HedgerRoute2Map[PriceOracleEntry] = expectedPriceOracleExit;

        if (PriceOracleEntry < expectedPriceOracleExit){
            return true;
        } 

        // require(PriceOracleEntry <= expectedPriceOracleExit, "Non-Profitable Route");
    }


    function checkSwapParams(uint amountIn) public view returns (bool, bool, uint) {

        // checking for 0<i< 5 $ : if  HedgerRoute2Map[i] > i -> return true 
        uint i = amountIn; //1000 $

        // -------  USED ONLY FOR CHECKING ------------
    
            if (HedgerRoute1Map[i] > i){
                bool param1 = true;
                bool param2 = false;
                i;
                return (param1, param2, amountIn);
            } else {
            if (HedgerRoute2Map[i] > i){

                bool param1 = false;
                bool param2 = true;
                i;
                return (param1, param2, amountIn);
                
            }       
        }

    }

}