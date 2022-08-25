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

    IUniswapV2Router02 Quickswap;
    IUniswapV2Router02 Sushiswap;  

    mapping( uint => uint ) public HedgerRoute1Map ; //mapping between amountIn and amoutOut 
    mapping( uint => uint ) public HedgerRoute2Map ; //mapping between amountIn and amoutOut


    address SANDAddress = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB; // Polygon
    address USDTAddress = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F; // Polygon

    address routerSushiswap = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506; // Sushiswap router on Polygon
    address routerQuickswap = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // Quickswap router on Polygon

    constructor() {
        Quickswap = IUniswapV2Router02(routerQuickswap);
        Sushiswap = IUniswapV2Router02(routerSushiswap);
    }
    
    // GET CONTRACT BALANCE
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function HedgerRoute1(uint256 amountIn) public {

        // USDT--> SAND         -------- Sushiswap --------- 
        //Sending USDT to the vault and approving 
        uint priceFeed1 = uint(getLatestPrice(priceFeedUSDT));
        uint PriceOracleEntry = priceFeed1 * amountIn; 


        require(IERC20(USDTAddress).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(USDTAddress).approve(routerSushiswap, amountIn), 'failed');

		address[] memory tokens = new address[](2);
		tokens[0] = USDTAddress;
		tokens[1] = SANDAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin1 = Sushiswap.getAmountsOut(amountIn, tokens)[1]; 


        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = USDTAddress;


        // -------- USED ONLY FOR CHECKING ----------- 
        uint priceFeedLast = uint(getLatestPrice(priceFeedUSDT));
        uint expectedOutMin2 = Quickswap.getAmountsOut(amountOutMin1, reverseTokens)[1];
        uint expectedPriceOracleExit = priceFeedLast * expectedOutMin2;
        HedgerRoute2Map[PriceOracleEntry] = expectedPriceOracleExit; 
        // -------  USED ONLY FOR CHECKING ------------


        // ------ SWAP CAN START NOW --------------------

		uint amounts = Sushiswap.swapExactTokensForTokens(amountIn, amountOutMin1, tokens, address(this), maxTimeToSwap)[1]; 
        require(amounts > 0, "Transaction aborted");

        //Reverse Swap : SAND --> USDT       ------ Quickswap ------ 
        //Calcul of new input token based on last price of Output Token :
        uint priceFeed2 = uint(getLatestPrice(priceFeedSAND));
        uint newAmountIn = amounts - ((amountIn * priceFeed1)/priceFeed2);

        //DO SECOND SWAP 
        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(SANDAddress).approve(routerQuickswap, newAmountIn), 'failed'); // Allowance of LINK 
        uint amountOutMin2 = Quickswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of USDT Token
        Quickswap.swapExactTokensForTokens(newAmountIn, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];
    

    }


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    function HedgerRoute2(uint256 amountIn) public {


        // USDT--> SAND         -------- Quickswap --------- 
        //Sending USDT to the vault and approving 
        uint priceFeed1 = uint(getLatestPrice(priceFeedUSDT));
        uint PriceOracleEntry = priceFeed1 * amountIn;  

        require(IERC20(USDTAddress).transferFrom(msg.sender, address(this), amountIn), 'failed');
        require(IERC20(USDTAddress).approve(routerQuickswap, amountIn), 'failed');

        
        address[] memory tokens = new address[](2);
		tokens[0] = USDTAddress;
		tokens[1] = SANDAddress;
		uint maxTimeToSwap = block.timestamp + 300;
        uint amountOutMin1 = Quickswap.getAmountsOut(amountIn, tokens)[1]; 

        address[] memory reverseTokens = new address[](2);
        reverseTokens[0] = SANDAddress; 
        reverseTokens[1] = USDTAddress;

        
         // -------- USED ONLY FOR CHECKING ----------- 
        uint priceFeedLast = uint(getLatestPrice(priceFeedUSDT));
        uint expectedOutMin2 = Sushiswap.getAmountsOut(amountOutMin1, reverseTokens)[1];
        uint expectedPriceOracleExit = priceFeedLast * expectedOutMin2;
        HedgerRoute2Map[PriceOracleEntry] = expectedPriceOracleExit; 
        // -------  USED ONLY FOR CHECKING ------------



		
        // ------ SWAP CAN START NOW --------------------
		uint amounts = Quickswap.swapExactTokensForTokens(amountIn, amountOutMin1, tokens, address(this), maxTimeToSwap)[1]; 
        require(amounts > 0, "Transaction aborted");


        //Reverse Swap : SAND --> USDT       ------ Sushiswap ------ 
        //Calcul of new input token based on last price of Output Token :
        uint priceFeed2 = uint(getLatestPrice(priceFeedSAND));
        uint newAmountIn = amounts - ((amountIn * priceFeed1)/priceFeed2);

        //DO SECOND SWAP 
        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), newAmountIn), 'failed');
        require(IERC20(SANDAddress).approve(routerSushiswap, newAmountIn), 'failed'); // Allowance of LINK 
       
        uint amountOutMin2 = Sushiswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of USDT Token
        Sushiswap.swapExactTokensForTokens(newAmountIn, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

    

    }



    function predictSwap() public view returns (uint){

    }


    function checkSwapParams() public view returns (bytes memory botCalls) {

        // checking for 0<i< 5 $ : if  HedgerRoute2Map[i] > i -> return true 
        uint i = 1000;
    
            if (HedgerRoute1Map[i] > i){
                bool param1 = true;
                bool param2 = false;
                uint amountIn = i;
                return abi.encodePacked(param1, param2, amountIn);
            } else {
            if (HedgerRoute2Map[i] > i){

                bool param1 = false;
                bool param2 = true;
                uint amountIn = i;
                return abi.encodePacked(param1, param2, amountIn);
                
            }

            

            
            
        }

    

    }

}