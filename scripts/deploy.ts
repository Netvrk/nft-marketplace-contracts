import { ethers, upgrades } from "hardhat";

async function main() {
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await upgrades.deployProxy(
    Marketplace,
    [process.env.OWNER_ADDRESS],
    {
      kind: "uups",
    }
  );
  await marketplace.deployed();
  console.log("ZensportsiaNft UUPS Proxy:", marketplace.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
