import { ethers } from "hardhat";

const decimal = 10 ** 4;

async function main() {
  const Merchant = await ethers.getContractFactory("Merchant");
  // replace your params
  const mch = await Merchant.deploy("startbuck", "stb", 10 * decimal, 1000 * decimal);

  await mch.deployed();

  console.log(`deploy Factory success, address is`, mch.address);
  process.exit(0);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
