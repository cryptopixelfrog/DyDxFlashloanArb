require('dotenv').config();
const Web3 = require('web3');
const fs = require('fs');
const Util = require("./utils/utils");
const web3 = new Web3(new Web3.providers.HttpProvider(process.env.NETENDPOINT));

const WethAddr = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2';
const TRADERACCOUNTADDR = process.env.TRADERWALLETADDR;
const DydxFlashArbContractAddr = process.env.DYDXFLASHLOANARB;
const DydxFlashArb =  JSON.parse(fs.readFileSync("./build/contracts/DyDxFlashloanArb.json"));
const DydxFlashArbInst = new web3.eth.Contract(DydxFlashArb.abi, DydxFlashArbContractAddr);
//how much the 1 eth coast. dont confuse this is not an amount of flashloan.
const srcQty = web3.utils.toHex(1 * 10 ** 18);
//The amount requested for this flashloan, this is amount of borrowing.
const loanAmount = 1;


async function DyDxFlashloanArbTrading(){
  let receiver_starting_bal = await web3.eth.getBalance(DydxFlashArbContractAddr);
  let wallet_starting_bal = await web3.eth.getBalance(TRADERACCOUNTADDR);

  var flashloanAmount = web3.utils.toHex(loanAmount * 10 ** 18);

  console.log('DyDxFlashloanArbTrading Creating tx');
  const tx =  DydxFlashArbInst.methods.getFlashloan(WethAddr, flashloanAmount);

  console.log('Sending tx');
  var rx = await Util.sendTransaction(web3, tx, TRADERACCOUNTADDR, process.env.PRIVATEKEY, DydxFlashArbContractAddr);
  console.log('Done');


  let receiver_ending_bal = await web3.eth.getBalance(DydxFlashArbContractAddr);
  console.log("Receiver Contract ETH starting balance: ", web3.utils.fromWei(receiver_starting_bal, 'ether'));
  console.log("Receiver Contract ETH ending balance: ", web3.utils.fromWei(receiver_ending_bal, 'ether'));
  let wallet_ending_bal = await web3.eth.getBalance(TRADERACCOUNTADDR);
  console.log("Trader Wallet ETH starting balance: ", web3.utils.fromWei(wallet_starting_bal, 'ether'));
  console.log("Trader Wallet ETH ending balance: ", web3.utils.fromWei(wallet_ending_bal, 'ether'));

  let receiver_diff = new web3.utils.BN(receiver_ending_bal).sub(new web3.utils.BN(receiver_starting_bal));
  console.log("<< Receiver Contract ETH Diff : " + web3.utils.fromWei(receiver_diff, 'ether') + " >>");
  let wallet_diff = new web3.utils.BN(wallet_ending_bal).sub(new web3.utils.BN(wallet_starting_bal));
  console.log("<< Trader Wallet ETH Diff : " + web3.utils.fromWei(wallet_diff, 'ether') + " >>");
  let total_spent = receiver_diff.add(wallet_diff);
  console.log("<< Total ETH Spent : " + web3.utils.fromWei(total_spent, 'ether') + " >>");

}
DyDxFlashloanArbTrading();
