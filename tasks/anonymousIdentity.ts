import { task } from "hardhat/config";
import type { HardhatRuntimeEnvironment } from "hardhat/types";

task("verify-identity", "Interact with AnonymousIdentityVerification contract")
  .addParam("contract", "The contract address")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { contract: contractAddress } = taskArgs;
    const { ethers } = hre;

    const AnonymousIdentityVerification = await ethers.getContractFactory("AnonymousIdentityVerification");
    const identityContract = AnonymousIdentityVerification.attach(contractAddress);

    console.log("Anonymous Identity Verification Contract at:", contractAddress);
    console.log("Total Verifications:", await identityContract.totalVerifications());
    console.log("Active Verification Requests:", await identityContract.activeVerificationRequests());
  });

task("get-identity-status", "Get identity proof status for an address")
  .addParam("contract", "The contract address")
  .addParam("address", "The user address to check")
  .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
    const { contract: contractAddress, address: userAddress } = taskArgs;
    const { ethers } = hre;

    const AnonymousIdentityVerification = await ethers.getContractFactory("AnonymousIdentityVerification");
    const identityContract = AnonymousIdentityVerification.attach(contractAddress);

    const proof = await identityContract.identityProofs(userAddress);
    console.log("Identity Proof Status for:", userAddress);
    console.log("Is Verified:", proof.isVerified);
    console.log("Is Active:", proof.isActive);
    console.log("Timestamp:", new Date(Number(proof.timestamp) * 1000).toLocaleString());
    console.log("Expiry Time:", new Date(Number(proof.expiryTime) * 1000).toLocaleString());
  });
