// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7; //fixed solidity version 

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./safeTransfer.sol";
import "./IUniswapV2.sol";


contract Botminator {

    using SafeTransfer for IERC20;


    ///@notice Funding the contract with X tokens to swap
    function fillContract(address token) external {
        //address tokenDAI  : 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        uint DAI;
        uint amountIn = 50 * 10 ** DAI;
        require(IERC20(token).transferFrom(msg.sender, address(this), amountIn), 'transferFrom failed.');
    }

    function CanTradeIn() public view returns (bool) {}


    ///@notice trade function to buy in a dex(router 1 || 2 ... ) and sell in another dex (router 2 || 3 || 4 ...)
    function trade() external {

    }





}