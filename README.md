# Arbitrage trading with DyDx Flashloan
Get Flashloan from DyDx, then do arbitrage trading between Kyber and Uniswap

## Setting
First, you need to create .env file and add those info in there.
```
DYDXFLASHLOANARB=
TRADERWALLETADDR=
PRIVATEKEY=
NETENDPOINT=http://localhost:8546 OR https://mainnet.infura.io/v3/KEY
```
DYDXFLASHLOANARB your contract URL, TRADERWALLETADDR is your personal wallet address, and PRIVATEKEY is your wallet's privatekey.
For NETENDPOINT, if you are using Infura, then add your infura dapp url. If you are using your local forked network, then you need to add http://localhost:PORT.

## Tips
### DyDx only supports those token assets:
```
// token address
address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address public SAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
```
### Kyber - tradeWithHint
```
KyberNetworkProxyInterface.tradeWithHint(
      srcToken, // source ERC20 token contract address
      srcQty, // source ERC20 token amount in its token decimals
      ETH_TOKEN_ADDRESS, // destination ERC20 token contract address
      address(this), // recipient address for destination ERC20 token
      10**28, // A limit on the amount of dest tokens
      minConversionRate, // The minimal conversion rate. If actual rate is lower, trade is canceled.
      address(0x0), // wallet address to send part of the fees to
      "PERM"
);
```
It is using Kyber's tradeWithHint to use Kyber's affiliate program. You can use swapTokenToToken instead.

### Ref
- Flashloan Tutorial - https://github.com/peppersec/flashloan-tutorial
- DyDx Documentation - https://docs.dydx.exchange/#/contracts
- DyDx Solo - https://github.com/dydxprotocol/solo
- money-lego - https://money-legos.studydefi.com/#/dydx
