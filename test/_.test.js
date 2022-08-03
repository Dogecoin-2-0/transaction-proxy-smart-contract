const { expect, use } = require("chai");
const { ethers, waffle } = require("hardhat");

use(waffle.solidity);

describe("Transaction Proxy", () => {
  /**
   * @type import('ethers').Contract
   */
  let transactionProxy;

  before(async () => {
    const TransactionProxyFactory = await ethers.getContractFactory("TransactionProxy");
    transactionProxy = await TransactionProxyFactory.deploy();
    transactionProxy = await transactionProxy.deployed();
  });

  it("should proxy transfer ether", async () => {
    const fee = await transactionProxy.calculateFee(ethers.utils.parseEther("5000"));
    console.log(ethers.utils.formatEther(fee));
    const [, signer2] = await ethers.getSigners();
    await expect(() =>
      transactionProxy.proxyTransferEther(signer2.address, { value: ethers.utils.parseEther("5000") })
    ).to.changeEtherBalance(signer2, ethers.utils.parseEther("5000").sub(fee));
  });
});
