import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const deployedAnonymousIdentityVerification = await deploy("AnonymousIdentityVerification", {
    from: deployer,
    log: true,
  });

  console.log(`AnonymousIdentityVerification contract deployed at:`, deployedAnonymousIdentityVerification.address);
};

export default func;
func.id = "deploy_anonymousIdentityVerification";
func.tags = ["AnonymousIdentityVerification"];
