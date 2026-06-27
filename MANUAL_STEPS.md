# Manual Steps — Ritual Price Oracle (Proof of Building)

Everything below must be done **by you** (secrets, wallet, GitHub, PoB form). The agent already built the contract and scripts.

---

## What was built

| Item | Path |
|------|------|
| Contract | `src/PriceOracle.sol` |
| Deploy script | `script/Deploy.s.sol` |
| Fund RitualWallet | `script/FundWallet.s.sol` |
| Fetch price | `script/FetchPrice.s.sol` |

**Behavior:** `fetchETHPrice()` calls CoinGecko over Ritual's **HTTP precompile** (`0x0801`), then parses `.ethereum.usd` with the **JQ precompile** (`0x0803`) in the **same transaction**.

---

## Step 1 — Create a wallet (if you don't have one)

1. Install [MetaMask](https://metamask.io/) (or Rabby).
2. Create a new account and **save the seed phrase offline**.
3. Copy your **public address** (starts with `0x`).

---

## Step 2 — Add Ritual testnet to your wallet

| Field | Value |
|-------|-------|
| Network name | Ritual Testnet |
| RPC URL | `https://rpc.ritualfoundation.org` |
| Chain ID | `1979` |
| Currency symbol | RITUAL |
| Block explorer | `https://explorer.ritualfoundation.org` |

---

## Step 3 — Get testnet RITUAL from the faucet

1. Open https://faucet.ritualfoundation.org
2. Paste your wallet address.
3. If the academy gave you an **access code**, enter it.
4. Claim tokens (you need RITUAL for **gas** and **RitualWallet** deposits).

**Minimum recommended:** ~0.1 RITUAL total (gas + one HTTP call).

---

## Step 4 — Configure your local `.env` (SECRET — do not commit)

In PowerShell, from the `ritual-price-oracle` folder:

```powershell
cd "D:\grock\Building with Ritualnet\First\ritual-price-oracle"
Copy-Item .env.example .env
```

Edit `.env` and set:

```env
PRIVATE_KEY=0xYOUR_ACTUAL_PRIVATE_KEY
RITUAL_RPC_URL=https://rpc.ritualfoundation.org
RITUAL_VERIFIER_URL=https://rpc.ritualfoundation.org/api/verify
```

**Never** push `.env` to GitHub.

---

## Step 5 — Compile and run tests (sanity check)

```powershell
forge build
forge test -vvv
```

You should see tests passing.

---

## Step 6 — Deploy to Ritual testnet

```powershell
forge script script/Deploy.s.sol:DeployScript --rpc-url $env:RITUAL_RPC_URL --broadcast -vvvv
```

**Save from the output:**

| Field | Example |
|-------|---------|
| Deployed contract address | `0xabc...` → set `ORACLE_ADDRESS` in `.env` |
| Deploy transaction hash | `0xdef...` → **PoB "deploy transaction"** |

Verify on explorer: `https://explorer.ritualfoundation.org/address/<ORACLE_ADDRESS>`

---

## Step 7 — Fund RitualWallet (required before HTTP calls)

Async HTTP calls deduct fees from **RitualWallet**, not your wallet balance directly.

Update `.env`:

```env
ORACLE_ADDRESS=0xYOUR_DEPLOYED_ADDRESS
```

Then run:

```powershell
forge script script/FundWallet.s.sol:FundWalletScript --rpc-url $env:RITUAL_RPC_URL --broadcast -vvvv
```

This sends **0.05 RITUAL** (default) into RitualWallet for your EOA.

---

## Step 8 — Fetch ETH price on-chain

**Important:** Only **one async job per wallet** at a time. Wait for each tx to finish before sending another.

```powershell
forge script script/FetchPrice.s.sol:FetchPriceScript --rpc-url $env:RITUAL_RPC_URL --broadcast -vvvv
```

- HTTP settlement usually takes **30–90 seconds**.
- If it reverts with `sender locked`, wait 2 minutes and retry.

**Verify success:**

```powershell
cast call $env:ORACLE_ADDRESS "latestPrice()(string)" --rpc-url $env:RITUAL_RPC_URL
cast call $env:ORACLE_ADDRESS "lastUpdatedBlock()(uint256)" --rpc-url $env:RITUAL_RPC_URL
```

You should see a price string (e.g. `"2456.78"`) and a block number > 0.

---

## Step 9 — (Optional) Verify contract source on explorer

```powershell
forge verify-contract --chain 1979 --watch --verifier custom --verifier-url $env:RITUAL_VERIFIER_URL --verifier-api-key unused $env:ORACLE_ADDRESS src/PriceOracle.sol:PriceOracle
```

---

## Step 10 — Push to GitHub (for PoB fork URL)

1. Create a GitHub account if needed.
2. Create a **new public repository** (e.g. `ritual-price-oracle`).
3. From the project folder:

```powershell
git init
git add .
git commit -m "Ritual PoB: on-chain ETH/USD price oracle (HTTP + JQ)"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ritual-price-oracle.git
git push -u origin main
```

**PoB fork URL:** `https://github.com/YOUR_USERNAME/ritual-price-oracle`

(If the form asks for a fork of `ritual-dapp-skills`, fork that repo on GitHub and push this project into it — or use your own repo if the form accepts any public repo with your code.)

---

## Step 11 — Submit Proof of Building

Fill the academy form while the session is open:

| Form field | Your value |
|------------|------------|
| **Fork URL** | `https://github.com/YOUR_USERNAME/ritual-price-oracle` |
| **Deployed contract** | `ORACLE_ADDRESS` from Step 6 |
| **Deploy transaction** | Deploy tx hash from Step 6 |
| **Short note** | See template below |

**Short note template (copy and adjust):**

> Built an on-chain ETH/USD price oracle on Ritual testnet (chain 1979). The `PriceOracle` contract fetches live data from CoinGecko using Ritual's native HTTP precompile (`0x0801`) and extracts the USD price with the JQ precompile (`0x0803`) in a single transaction. RitualWallet was funded for async execution fees.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `transaction type not supported` | Do not use `--legacy`. Foundry uses EIP-1559 by default. |
| `sender locked` | Wait for pending async job to settle (~2 min), then retry. |
| `no HTTP executor` | Testnet executor issue — retry later or ask in Discord. |
| `insufficient funds` | Claim more RITUAL from faucet. |
| HTTP 429 / rate limit | CoinGecko throttled — wait 1 minute and retry. |
| `JQ query failed` | CoinGecko response shape changed — check `latestPrice` event logs. |

**Discord:** https://discord.com/invite/ritual-net

---

## PoB checklist

- [ ] Wallet funded from faucet
- [ ] `.env` configured (not committed)
- [ ] `forge test` passes
- [ ] Contract deployed — address saved
- [ ] Deploy tx hash saved
- [ ] RitualWallet funded (`fundWallet`)
- [ ] `fetchETHPrice()` succeeded — `latestPrice` non-empty
- [ ] Code pushed to public GitHub
- [ ] PoB form submitted