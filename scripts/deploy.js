const fs = require("fs");
const path = require("path");
const { ethers, network } = require("hardhat");

async function deploy() {
  console.log("Now deploying on ", network.name);
  const TransactionProxyFactory = await ethers.getContractFactory("TransactionProxy");
  let proxy = await TransactionProxyFactory.deploy();
  proxy = await proxy.deployed();

  const location = path.join(__dirname, "../addresses.json");
  const fileExists = fs.existsSync(location);

  if (fileExists) {
    const buf = fs.readFileSync(location);
    const val = JSON.parse(buf.toString());
    const updatedVal = { ...val, [network.name]: proxy.address };

    fs.writeFileSync(location, JSON.stringify(updatedVal, undefined, 2));
  } else {
    fs.writeFileSync(location, JSON.stringify({ [network.name]: proxy.address }, undefined, 2));
  }

  console.log("Contract deployed on address ", proxy.address);
}

(async () => {
  await deploy();
})();
