# IntegrumSwap 

This is our EthGlobal Brussels hackathon project.

*IntegrumSwap* is a decentralised *cross chain exchange* that inherits the best of two worlds: AMMs like Uniswap and Coincidence of Wants dexes like CoWSwap.

![Comparison](Comparison.png)

Uniswap runs on-chain and thus is decentralised, but we all know about the MEV and front-running issues. That happens mainly because AMMs do not work with fixed pricing of swaps and so someone can change the price of a token just before your order executes.
IntegrumSwap does not suffer from these issues because like CoW Swap, it uses coincidence of wants to fulfill trade orders.
CoW Swap uses off-chain order matching and thus is not decentralised and is vulnerable. IntegrumSwap runs the order matching engine on-chain using Arbitrum WASM VM. That is an order of magnitude faster than EVM with significantly lower gas fees. That is due to the superior efficiency of WASM programs. Also memory can be 100-500 times cheaper.

Neither Uniswap nor CoW Swap trades are cross chain. That means that we get into the problem of liquidity fragmentation for a trading pair. IntegrumSwap uses LayerZero to implement interoperability and thus works cross-chain.

For example a user holding tokens on Optimism can trade with a user that holds tokens on say - Ethereum. They do not have to go through bridging, swapping and bridging back to the source chain. Both traders get the counterpart tokens on their home chain.  
 
Integrum also implements a Uniswap V4 hook. If the users get better prices in local liquidity pool, the default swap logic is executed locally. Otherwise, if the user can get a better market order price on a remote chain, they go through LayerZero and the tokens are bridged accordingly across chains. 

We have deployed Integrum contracts on Ethereum Sepolia, Celo Alfajores, Base Sepolia, Scroll Sepolia, Linea Sepolia, BNB Smart Chain Testnet and Optimism Sepolia. The order matching engine is deployed on Arbitrum Sepolia.

### Architecture

![Architecture](Architecture.png)

### How to run

Build the main project.
```
forge build
```

Build Rust contract (Stylus)
```
cargo stylus check -e https://sepolia-rollup.arbitrum.io/rpc
```

Deploy OrderMatcher Rust contract
```
cargo stylus deploy --private-key=$PRIV_KEY -e https://sepolia-rollup.arbitrum.io/rpc
```

Frontend
```
cd ui
yarn install
yarn start
```
Open app on [http://localhost:3000](http://localhost:3000)

### Arbitrum Stylus

IntegrumSwap uses Arbitrum Stylus to implement an order matching engine to which all the limit and market orders are sent. It is written as a smart contract in Rust.
So what if we reach the limit that Arbitrum Stylus supports through it’s WASM VM? It should be easy to implement sharding with multiple matching engines each taking care of a slice of the orderbook.

The OrderMatching contract is implemented in Rust [here](order-matcher/src/lib.rs).

| Chain            | OrderMatcher                                | OrderMatcherWrapper                               
| ---------------- | ------------------------------------------- | ------------------------------------------ |
| Arbitrum         | 0xAEC85ff2A37Ac2E0F277667bFc1Ce1ffFa6d782A  | 0x3A274DD833726D9CfDb6cBc23534B2cF5e892347 |                                     

### LayerZero

To communitcate between chains, IntegrumSwap uses LayerZero. For the hackathon we have deployed end-points to Ethereum, Optimism, Scroll, Base, Celo and Linea. They are all Solidity contracts that send limit or market orders using LayerZero to the matching engine that lives on Arbitrum Stylus.
After the orders are matched, each individual endpoint uses OFT to settle the tokens.

See the code:
[https://github.com/scarfish-dapps/integrum-swap/blob/IntegerSwapV2/src/OrderPlacerProxy.sol](https://github.com/scarfish-dapps/integrum-swap/blob/IntegerSwapV2/src/OrderPlacerProxy.sol) and 
[https://github.com/scarfish-dapps/integrum-swap/blob/IntegerSwapV2/src/OrderMatcherWrapper.sol](https://github.com/scarfish-dapps/integrum-swap/blob/IntegerSwapV2/src/OrderMatcherWrapper.sol)

Deployed OFTs:

| Name            | Symbol                                             | Optimism Sepolia                           | Ethereum Sepolia                           |
| --------------- | -------------------------------------------------- | ------------------------------------------ | ------------------------------------------ | 
| BrusselsOFT     | BOFT                                               | 0x40aDe76a75066c6f6Ef4Dd18AA6218592dEA0799 | 0xAe3C07deA15BB038B59191F24Ad1d18c76F9df83 |
| IntegrumOFT     | IOFT                                               | 0xCCe7C75Eb1D1D710F1e60E1335a8F44f197FE2af | 0xAe3C07deA15BB038B59191F24Ad1d18c76F9df83 |


### Uniswap V4

For market orders, IntegrumSwap implements a Uniswap hook. If the hook sees that there are better prices on other chains, instead of doing the swap with the local liquidity pool, it bypasses the default logic and sends a market order through LayerZero to the matching engine on Arbitrum Stylus. 

Hook deployment address: 0xbe45E53EFd261abA6E9fBf4bf2ddd8618B628088

Hook source code: https://github.com/scarfish-dapps/integrum-swap/blob/main/src/EntryPoint.sol

### WalletConnect

WalletConnect is utilized to access the wallet provider connected through Web3Modal. This integration allows the app to interact with the blockchain and facilitates seamless network switching. Additionally, the app customizes the wallet information display, providing users with an enhanced experience.
Source file is [here](https://github.com/scarfish-dapps/integrum-swap/blob/main/ui/src/components/walletProfile/WalletProfile.tsx)

### Base

The contracts MainContract and OrderPlacerProxy were deployed on Base to enable cross-chain swaps via LayerZero.

### Scroll

The contracts MainContract and OrderPlacerProxy were deployed on Base to enable cross-chain swaps via LayerZero.

### Cello

The contracts MainContract and OrderPlacerProxy were deployed on Base to enable cross-chain swaps via LayerZero.

### Blockscout

By integrating Blockscout, we ensure that users can easily verify and audit transactions, enhancing transparency and trust in IntegrumSwap. 


#### Contract Addresses 

| Chain            | MainContract                                | OrderPlacerProxy                              
| ---------------- | ------------------------------------------- | ------------------------------------------ |
| Ethereum         | 0xAEC85ff2A37Ac2E0F277667bFc1Ce1ffFa6d782A  | 0xc42578B466355875F1F24a3D98aA78e0DA4f2232 |                                          
| Linea            | 0xAEC85ff2A37Ac2E0F277667bFc1Ce1ffFa6d782A  | 0x36DE04BFBc2AB1cE497c063E7560137c7f7579fB |                                          
| Optimism         | 0x24b8cd32f93aC877D4Cc6da2369d73a6aC47Cb7b  | 0xBD345337127768a4578F8D3753bB182E4Cc513E8 |                                          
| Scroll           | 0xf4661D0776Ee5171956b25417F7E320fE365C21E  | 0x36DE04BFBc2AB1cE497c063E7560137c7f7579fB |                                          
| Base             | 0xf4661D0776Ee5171956b25417F7E320fE365C21E  | 0xBD345337127768a4578F8D3753bB182E4Cc513E8 |                                          
| Cello            | 0xf4661D0776Ee5171956b25417F7E320fE365C21E  | 0xD1E1F57E41A54c930664Ed799c753e330734Da66 |                                          

