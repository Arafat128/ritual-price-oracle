# Ritual Price Oracle

On-chain ETH/USD price feed for [Ritual Chain](https://docs.ritualfoundation.org) testnet (chain ID **1979**).

Fetches live data from CoinGecko using:

- **HTTP precompile** (`0x0801`) — short-running async
- **JQ precompile** (`0x0803`) — synchronous JSON extraction

## Quick start

See **[MANUAL_STEPS.md](./MANUAL_STEPS.md)** for the full Proof of Building workflow.

```powershell
forge build
forge test -vvv
forge script script/Deploy.s.sol:DeployScript --rpc-url $env:RITUAL_RPC_URL --broadcast -vvvv
```

## Contract

`PriceOracle.sol` exposes:

- `fundWallet()` — deposit RITUAL into RitualWallet for async fees
- `fetchETHPrice()` — auto-pick HTTP executor, fetch and store price
- `latestPrice()` — last ETH/USD price (string)
- `lastUpdatedBlock()` — block number of last successful fetch

## License

MIT