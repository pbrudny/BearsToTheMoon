
# BearHunter Token

BearHunter is an ERC20 token designed to create a deflationary environment for the Bears To The Moon token by burning Bears To The Moon tokens and minting BearHunter tokens. This mechanism aims to reduce the supply of Bears To The Moon tokens, potentially increasing their scarcity and value.

## Features

- **Burning Mechanism**: Burn 100 Bears To The Moon tokens to mint 1 BearHunter token.
- **Automatic Liquidity Addition**: Collects transaction fees and automatically swaps and adds liquidity using Uniswap.
- **Trading Enablement**: Allows the owner to enable or disable trading.

## Token Details

- **Name**: Bear Hunter
- **Symbol**: BEARH
- **Decimals**: 18
- **Max Supply**: 10,000,000 BEARH

## Smart Contract Address

- **Bears To The Moon Token Address**: `0xF1A42B7b96BA15250b05820B44b66DF00791EF25`
- **Uniswap V2 Router Address**: `0xc1f90231035A52091eBCb7dddaCa3051a5F44f30` (Mainnet)

## Functions

### Public Functions

- **burnBearsToMintBearHunter**: Burns Bears To The Moon tokens to mint BearHunter tokens at a rate of 100:1.
  ```solidity
  function burnBearsToMintBearHunter(uint256 bearsAmount) external;
  ```
  - `bearsAmount`: Amount of Bears To The Moon tokens to burn (must be a multiple of 100).

### Owner Functions

- **excludeFromFees**: Excludes an account from transaction fees.
  ```solidity
  function excludeFromFees(address account, bool excluded) external onlyOwner;
  ```

- **setAutomatedMarketMakerPair**: Sets or unsets an automated market maker pair.
  ```solidity
  function setAutomatedMarketMakerPair(address pair, bool value) external onlyOwner;
  ```

- **enableTrading**: Enables trading by setting `swapEnabled` to true.
  ```solidity
  function enableTrading() external onlyOwner;
  ```

- **withdrawERC20**: Allows the owner to withdraw mistakenly sent ERC20 tokens.
  ```solidity
  function withdrawERC20(address tokenAddress, uint256 amount) external onlyOwner;
  ```

## Deployment

To deploy the BearHunter contract, follow these steps:

1. **Open Remix**: Go to [Remix IDE](https://remix.ethereum.org/).
2. **Create a New File**: Create a new file named `BearHunter.sol` and paste the contract code.
3. **Compile the Contract**: Compile the contract using Solidity version `0.8.20`.
4. **Deploy the Contract**:
   - In the "Deploy & Run Transactions" tab, select "Injected Web3" to connect to MetaMask.
   - Ensure your wallet is connected to the Ethereum mainnet.
   - Deploy the `BearHunter` contract.

## Example Usage

1. **Burn Bears To The Moon Tokens**: Call the `burnBearsToMintBearHunter` function to burn Bears To The Moon tokens and mint BearHunter tokens.
   ```solidity
   bearHunter.burnBearsToMintBearHunter(1000); // Burns 1000 Bears To The Moon tokens and mints 10 BearHunter tokens
   ```

2. **Enable Trading**: Call the `enableTrading` function to enable trading.
   ```solidity
   bearHunter.enableTrading();
   ```

3. **Exclude From Fees**: Exclude an account from transaction fees.
   ```solidity
   bearHunter.excludeFromFees(account, true);
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

