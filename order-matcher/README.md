# IntegrumSwap Mathcing Engine

### How to run

Build Rust contract (Stylus)
```
cargo stylus check -e https://sepolia-rollup.arbitrum.io/rpc
```

Deploy OrderMatcher Rust contract
```
cargo stylus deploy --private-key=$PRIV_KEY -e https://sepolia-rollup.arbitrum.io/rpc
```

### Arbitrum Stylus

IntegrumSwap uses Arbitrum Stylus to implement an order matching engine to which all the limit and market orders are sent. It is written as a smart contract in Rust.
So what if we reach the limit that Arbitrum Stylus supports through it’s WASM VM? It should be easy to implement sharding with multiple matching engines each taking care of a slice of the orderbook.

The OrderMatching contract is implemented here.

For the description of the entire project, see the README from the main project