# Ritual Price Oracle

On-chain ETH/USD price feed for [Ritual Chain](https://docs.ritualfoundation.org) testnet (chain ID **1979**).

Fetches live data from CoinGecko using:

- **HTTP precompile** (`0x0801`) — short-running async
- **JQ precompile** (`0x0803`) — synchronous JSON extraction

Built for Ritual Academy Proof of Building: the `PriceOracle` contract fetches live data from CoinGecko via Ritual's HTTP precompile and extracts the USD price with the JQ precompile in a single transaction.

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

## Deployed (testnet)

| Field | Value |
|-------|-------|
| Contract | `0xe56C9C9a263fEcEDA70293D85D96b2058f31698d` |
| Deploy tx | `0x949ed0a91ec65cd7826fcea9fea312c92cb7f43253ae14a980c7be12eda9622b` |

## License

MIT