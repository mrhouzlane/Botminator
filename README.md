## Botminator                 

🪢🪢 This is the official repository for Chainlink Hackathon with Encode Club 2022 🪢🪢

You cannot be a real market maker in markets like NYSE, controlled by capital ventures (private clubs). Motivation to build a bot comes with this incentive offered by decentralized exchanges offering direct access to the market with APIs for example.
Botminator is an arbitrage bot taking advantage of chainlink price feed oracle and chainlink keepers for cross exchange trading based on Proof Of Variation. 


### Contracts 

- BotminatorVault deployed : [Mumbai  contract](https://mumbai.polygonscan.com/address/0x5bEa99Fcdca784bB9EbBF7a070FEB567a55581D5)
- BotminatorKeeper deployed : [Mumbai  contract](https://mumbai.polygonscan.com/address/0x38e35ae9fb9E1d0228495CB66AD51B9B095D5f6A)


### How it works : Proof of Price Variation 


![PoPV](./docs/PoV.png)


- SAND : Output in token amount after swap.  
- SAND* : Input in token amount to swap in the 2nd swap of a route based on Input in USD to be profitable. 

 
### ChainLink Integration 


- PriceFeed Oracle : 
<img width="595" alt="Screenshot 2022-08-29 at 05 29 05" src="https://user-images.githubusercontent.com/75360886/187117378-d88421eb-29ab-4a39-90ff-344bb1b3683f.png">
<img width="528" alt="Screenshot 2022-08-29 at 05 29 24" src="https://user-images.githubusercontent.com/75360886/187117405-3d0d49d7-5180-42ea-a18d-445fee0df007.png">


- Keeper Automation : 
<img width="744" alt="Screenshot 2022-08-29 at 05 28 42" src="https://user-images.githubusercontent.com/75360886/187117330-4bda4712-6722-4d52-93ee-b63f86a3af1d.png">



### Inspiration 

To reduce the risk of having a sandwich attack AMM DEXs began offering Time Weighted Average Price (TWAP) oracles. TWAP is a pricing methodology that calculates the mean price of an asset during a specified period of time. For example, a “one-hour TWAP” means taking the average price over a defined hour of time. 


Cross-exchange market making :

- Less liquid market : make order 
- More Liquid market : taker order 


### Strategy 

It is important to choose the right dex or in other words the route to be profitable, and for this you have to : 

- Take into account the tax(fees) in the arbitrage while setting up orders. 
- Oracle exchange price feed choice : not necessarily the connected exchange <depends on strategy : more liquid exchange will give you more insight into the potential direction of token price> 


### Analysis Tools 

[Analysis tool for dexs](https://defillama.com/)


### Chainlink Integration 

- PriceFeed 
- Keepers 

### Advantages 

- Chainlink Keepers can execute a portion of the code deployed on-chain at a basic minimum web dev costs. 
- Distinct service that only compute code for that contract on-chain. 
- Save Ethereum fees. 
- Privacy 

### Future 

- Friendly user-interface. 
