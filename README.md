# 🔄 Base Zero-Slippage Swap

A secure, Fixed-Rate OTC Swap smart contract deployed on Base Mainnet. This contract eliminates slippage entirely by utilizing a pre-defined exchange rate rather than an Automated Market Maker (AMM) curve.

## 🌟 Key Features
- **0% Slippage:** Exact 1-to-1 or custom ratio swaps.
- **Gas Optimized:** Lightweight logic without complex mathematical curves.
- **Secure:** Built with OpenZeppelin `SafeERC20` and `ReentrancyGuard`.
- **Base Ready:** Configured perfectly for Base Mainnet and Base Sepolia.

## ⚙️ How It Works
The contract acts as a decentralized vending machine:
1. The Owner provisions the contract with liquidity (`TokenOut`).
2. The Owner sets an exact `exchangeRate`.
3. Users approve and swap `TokenIn` to receive `TokenOut` instantly at the exact guaranteed rate.

## 🚀 Quick Start

### 1. Installation
```bash
npm install

2. Environment Setup
Copy .env.example to .env and fill in your details:

Bash
cp .env.example .env
3. Compilation
Bash
npx hardhat compile
4. Deployment
Deploy to Base Mainnet:

Bash
npx hardhat run scripts/deploy.ts --network base_mainnet
5. Verification
Verify your contract automatically on BaseScan:

Bash
npx hardhat verify --network base_mainnet <DEPLOYED_CONTRACT_ADDRESS> <TOKEN_IN_ADDRESS> <TOKEN_OUT_ADDRESS> <INITIAL_RATE>
🔒 Security
This repository is for educational and technical demonstration purposes. Ensure you conduct proper audits before committing large amounts of liquidity on Mainnet.
