import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const TOKEN_IN = "0x..."; 
  const TOKEN_OUT = "0x..."; 
  const INITIAL_RATE = 2; 
  const FEE_BPS = 30; // 0.3%
  const TREASURY = deployer.address;

  const SwapFactory = await ethers.getContractFactory("FixedRateSwapPro");
  const swapContract = await SwapFactory.deploy(
    TOKEN_IN,
    TOKEN_OUT,
    INITIAL_RATE,
    FEE_BPS,
    TREASURY
  );

  await swapContract.waitForDeployment();
  const address = await swapContract.getAddress();

  console.log(`FixedRateSwapPro deployed to: ${address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
