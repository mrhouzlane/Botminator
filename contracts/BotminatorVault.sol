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


    address DAIAddress = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063; // Polygon
    address SANDAddress = 0xC6d54D2f624bc83815b49d9c2203b1330B841cA0; // Polygon
    address LINKAddress = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39; // Polygon
    address routerSushiswap = 0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506		; // Polygon
    address routerQuickswap = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32	; // Polygon 

    constructor() {
        Quickswap = IUniswapV2Router02(routerQuickswap);
        Sushiswap = IUniswapV2Router02(routerSushiswap);
    }

    // function transferLink() external payable {
    //     require(msg.value <= 0.1 ether);
    //     IERC20(LINKAddress).transferFrom(msg.sender, address(this), 2);
    // }


    ///@notice getting liquidity from illiquid market and selling in liquid market
    ///@dev amountIn is the amount in dollars that you want to spend 
    function HedgerRoute1(uint256 amountIn) external payable {

        // DAI--> SAND         -------- Sushiswap --------- 

        //how much DAI we have with amountIn USD
        uint amountInTokens = uint(getPriceRate(priceFeedDAI, amountIn));

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

        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), amounts), 'failed');
        require(IERC20(SANDAddress).approve(routerQuickswap, amounts), 'failed'); // Allowance of LINK 
        uint amountOutMin2 = Quickswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of DAI Token
        Quickswap.swapExactTokensForTokens(amounts, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

    }


    ///@notice getting liquidity from illiquid market and selling in liquid market 
    ///@dev amountIn is the amount in dollars that you want to spend 
    function HedgerRoute2(uint256 amountIn) public {

        
        // DAI--> SAND         -------- QUICKSWAP --------- 

        //how much DAI we have with amountIn USD
        uint amountInTokens = uint(getPriceRate(priceFeedDAI, amountIn));

        require(IERC20(DAIAddress).transferFrom(msg.sender, address(this), amountInTokens), 'failed');
        require(IERC20(DAIAddress).approve(routerSushiswap, amountInTokens), 'failed');

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

        //Reverse Swap : SAND --> DAI       ------ SUSHISWAP ------ 

        require(IERC20(SANDAddress).transferFrom(msg.sender, address(this), amounts), 'failed');
        require(IERC20(SANDAddress).approve(routerSushiswap, amounts), 'failed'); // Allowance of LINK 
        uint amountOutMin2 = Sushiswap.getAmountsOut(amounts, reverseTokens)[1]; //AmountOutMin of DAI Token
        Sushiswap.swapExactTokensForTokens(amounts, amountOutMin2, reverseTokens, address(this), maxTimeToSwap)[1];

    
    }

    function predictSwapOracleRoute1(uint numberOfTokenIn, uint amountIn) external returns (bool) {

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
        uint priceFeed1 = uint(getPriceRate(priceFeedDAI, amountIn));
        uint PriceOracleEntry = priceFeed1 * numberOfTokenIn;  
        uint priceFeedLast = uint(getPriceRate(priceFeedDAI, amountIn));
        uint expectedPriceOracleExit = priceFeedLast * expectedOutMin2; 
        
        HedgerRoute1Map[PriceOracleEntry] = expectedPriceOracleExit;

        if (PriceOracleEntry < expectedPriceOracleExit){
            return true;
        } 

    }


    function predictSwapOracleRoute2(uint numberOfTokenIn, uint amountIn) external returns (bool) {

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
        uint priceFeed1 = uint(getPriceRate(priceFeedDAI, amountIn));
        uint PriceOracleEntry = priceFeed1 * numberOfTokenIn;  
        uint priceFeedLast = uint(getPriceRate(priceFeedDAI, amountIn));
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