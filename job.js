import {ethers} from 'ethers';

const addresses = {
    UNI : "",
    factory : "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f",
    router : "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
}

const recipient = "0xA071F1BC494507aeF4bc5038B8922641c320d486" ;

//Address with token to buy : tokenIN 
const tokenBuyer = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2" // Wrapped Ethereum token (WETH)



// mnemoic for the wallet to pay for tx fees aka taxes ughhh : 
const mnemonic = "impact amount garlic cliff surge resource they long illegal soul address scan";

const provider = new ethers.providers.WebSocketProvider("ANKR")
const wallet = ethers.Wallet.fromMnemonic(mnemonic);
const account = wallet.connect(provider); //signing tx

const factory = new ethers.Contract(
    addresses.factory,
    ['event PairCreated(address indexed token0, address indexed token1, address pair, uint)'],// human redeable ABI with ethers library ;
    account
)

const router = new ethers.Contract(
    addresses.router,
    [
        'function getAmountsOut(uint amountIn, address[] memory path) internal view returns (uint[] memory amounts)',
        'function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts)' 
    ],
    account
);

factory.on('PairCreated', async (token0, token1, pairAddress) => {
    
    console.log(`
    ------ New Liquidity pool --------
    token0: ${token0}
    token1 : ${token1}
    pairAddress : ${pairAddress}`)




    // ------- TOKEN PURCHASER ----------
    let tokenIn, tokenOut;
    if (token0 == tokenBuyer) {
        tokenIn = token0;
        tokenOut = token1;
    }

    if (token1 == tokenBuyer) {
        tokenIn = token1;
        tokenOut = token0
    }

    if (typeof tokenIn == 'undefined') {
        return;
    }


    //Buying Process and Parameters 

    // Strategy : 

    // 1. Buying "x" amount with buyerToken WETH :
    const amountIn = ethers.utils.parseUnits('0.1', 'ether');
    const amounts = await router.getAmountsOut(amountIn, [tokenIn, tokenOut]); //calculates the [] output  -- pair of toke[0,1] --> output amount  --

    // 2. We accept only x % of the amount max ~ 96 % of the max --> amounts

    percentage = div(4)
    const amountOutRequired = amounts[1].sub(amounts[1].div(4)) //4% because 100-96 = 4 
    console.log(`

        ------- Buying Process launched ---- :
        tokenIn = ${amountIn.toString()} ${tokenIn}
        tokenOut = ${amountOutRequired.toString()} ${tokenOut}
        `
    );

    // 3. Launch the swap 

    const tx = await router.swapExactTokensForTokens(
        amountIn,
        amountOutRequired,
        [tokenIn, tokenOut],
        recipient,
        Date.now() + 1000* 60 * 15 // 15 minutes 
    );

    const receipt = await tx.wait();
    console.log("Transaction receipt");
    console.log("receipt");

});


