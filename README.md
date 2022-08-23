## BOTMINATOR 

🪢🪢 This is the official repository for Chainlink Hackathon with Encode Club 2022 🪢🪢

##### REMINDER -- THIS IS NOT A FLASHSWAP BUT A TRADING USE CASE WITH CHAINLINK KEEPERS -- YOU DO YOU, WE ARE NOT RESPONSIBLE FOR ANY LOSSES -- 

### Strategy : 

Cross-exchange market making :

- Less liquid market : make order 
- More Liquid market : taker order 


### Strategy to choose the "right" DEX : 

- Take into account the tax(fees) in the arbitrage while setting up orders. 
- Oracle exchange price feed choice : not necessarily the connected exchange <depends on strategy : more liquid exchange will give you more insight into the potential direction of token price> 


### Analysis Tools : 

[DeFiLLAMA](https://defillama.com/)


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------------------------------------------

### CHAINLINK KEEPERS 

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


