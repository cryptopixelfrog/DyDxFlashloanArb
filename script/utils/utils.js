const fs = require('fs');
require('dotenv').config();
const https = require('https');
const request = require('request');

exports.sendTransaction = async function (web3, tx, Account, PrivateKey, ToAddress){

  var encodedABI = tx.encodeABI();
  var txCount = await web3.eth.getTransactionCount(Account);
  var networkId = await web3.eth.net.getId();

  var txData = {
    //nonce: web3.utils.toHex(txCount),
    gasLimit: web3.utils.toHex(1000000),
    gasPrice: web3.utils.toHex(4000),    // Should look at optimising this.
    to: ToAddress,
    from: Account,
    data: encodedABI,
    chainId: networkId
  }
  var signedTx = await web3.eth.accounts.signTransaction(txData, '0x' + process.env.PRIVATEKEY);

  const receipt = await web3.eth.sendSignedTransaction(
    signedTx.rawTransaction,
    async (err, data) => {
      if (err) {
        console.error("sendSignedTransaction error", err);
      }
    }
  ).on("receipt", receipt => console.log("receipt", receipt));

  console.log('Transaction done.');
}
