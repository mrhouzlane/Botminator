This is the official repository for Chainlink Hackathon with Encode Club 2022 🎛.


## Strategy choosen : 

Cross-exchange market making :

- Less liquid market : make order 
- More Liquid market : taker order 



 DDEX & Binance. 
 
 Arbitrage lock 1$ profit between a : 
 - buy at 90$ for example in Binance.
 - sell at 91$ for example in DDEX 
 
**In this strategy in making the profit, we should look at the fees bor been a maker in one dex and taker in another one.**
 
 


## MoodyLink 

 Triggers automated trading strategy by :
 
- Managing [open-close] orders / computation using off-chain computation with Chainlink Keepers. 
- Adding gas price conditions to meet the checkUpkeep conditions to true only if gasLimit  is lower than x value 
- ...
- ...

## Why ?

- Chainlink Keepers can execute a portion of the code deployed on-chain at a basic minimum web dev costs. 
- Distinct service that only compute code for that contract on-chain. 
- Save Ethereum fees. 
- Privacy 

## Future : 


