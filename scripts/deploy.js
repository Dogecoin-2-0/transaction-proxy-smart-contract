const { ethers, network } = require("hardhat");

async function deploy() {
  console.log("Now deploying on ", network.name);
  const TransactionProxyFactory = await ethers.getContractFactory("TransactionProxy");
  let proxy = await TransactionProxyFactory.deploy();
  proxy = await proxy.deployed();

  console.log("Contract deployed on address ", proxy.address);
}

(async () => {
  await deploy();
})();
