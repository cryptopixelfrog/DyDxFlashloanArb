pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./Kyber/KyberNetworkProxyInterface.sol";
import "./dydx/DyDxFlashloan.sol";

contract DyDxFlashloanArb is DyDxFlashLoan{

  address arbOwner;

  KyberNetworkProxyInterface public proxy;
  ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  ERC20 constant internal wethToken = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  ERC20 constant internal wbtcToken = ERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);

  constructor(KyberNetworkProxyInterface _proxy) public payable {
    // The loan is initiated by the borrower
    proxy = _proxy;
    arbOwner = msg.sender;
    (bool success, ) = WETH.call.value(msg.value)("");
    require(success, "fail to get weth");
  }

  modifier onlyOwner () {
    require(msg.sender == arbOwner);
    _;
  }

  function () external payable {}


  function getFlashloan(
    address _flashToken,
    uint256 _flashAmount
  )
    external
  {
      uint256 _balanceBefore = IERC20(_flashToken).balanceOf(address(this));
      bytes memory _data = abi.encode(_flashToken, _flashAmount, _balanceBefore);
      flashloan(_flashToken, _flashAmount, _data); // execution goes to `callFunction`
      // and this point we have succefully paid the dept
  }


  // dydx call back
  function callFunction(
    address, // sender
    Info calldata, // accountInfo
    bytes calldata _data
  )
    external onlyPool
  {
    (address flashToken, uint256 flashAmount, uint256 balanceBefore) = abi.decode(_data, (address, uint256, uint256));
    uint256 balanceAfter = IERC20(flashToken).balanceOf(address(this));
    require(balanceAfter - balanceBefore == flashAmount, "contract did not get the loan");

    arbTrade();
  }


  function arbTrade() public {
    uint wethQty = wethToken.balanceOf(address(this));
    _kyberTrade(wethToken, wethQty, wbtcToken, address(this));
    //_uniswapTrade();
  }

  function _kyberTrade(
    ERC20 srcToken,
    uint srcQty,
    ERC20 destToken,
    address destAddress
  )
    internal
  {
    uint minConversionRate;
    // Mitigate ERC20 Approve front-running attack, by initially setting
    // allowance to 0
    require(srcToken.approve(address(proxy), 0));
    // Set the spender's token allowance to tokenQty
    require(srcToken.approve(address(proxy), srcQty));
    // Get the minimum conversion rate
    (minConversionRate,) = proxy.getExpectedRate(srcToken, ETH_TOKEN_ADDRESS, srcQty);

    // Swap the ERC20 token to ETH
    // this works with bnt, but not with wbtc.
    //uint destAmount = proxy.swapTokenToToken(srcToken, srcQty, destToken, minConversionRate);
    uint weth_to_eth = proxy.tradeWithHint(
                                            srcToken, // source ERC20 token contract address
                                            srcQty, // source ERC20 token amount in its token decimals
                                            ETH_TOKEN_ADDRESS, // destination ERC20 token contract address
                                            address(0x174B3C5f95c9F27Da6758C8Ca941b8FFbD01d330), // recipient address for destination ERC20 token
                                            10**28, // A limit on the amount of dest tokens
                                            minConversionRate, // The minimal conversion rate. If actual rate is lower, trade is canceled.
                                            address(0x174B3C5f95c9F27Da6758C8Ca941b8FFbD01d330), // wallet address to send part of the fees to
                                            "PERM"
                                          );

    uint _wbtcexpectedRate;
    (_wbtcexpectedRate,) = proxy.getExpectedRate(ETH_TOKEN_ADDRESS, destToken, weth_to_eth);
    //
    uint destAmount = proxy.tradeWithHint.value(weth_to_eth)(
                                            ETH_TOKEN_ADDRESS, // source ERC20 token contract address
                                            weth_to_eth, //weth_to_eth, // source ERC20 token amount in its token decimals
                                            destToken, // destination ERC20 token contract address
                                            address(this), // recipient address for destination ERC20 token
                                            10**30, // A limit on the amount of dest tokens
                                            _wbtcexpectedRate, // The minimal conversion rate. If actual rate is lower, trade is canceled.
                                            address(0x174B3C5f95c9F27Da6758C8Ca941b8FFbD01d330), // wallet address to send part of the fees to
                                            "PERM"
                                          );
  }


  function _uniSwapTrade(
    ERC20 srcToken,
    uint256 tokenSold,
    uint256 _maxTokensSell
  )
    internal
  {
    //
  }

}
