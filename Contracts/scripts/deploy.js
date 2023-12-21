require('dotenv').config();

async function main() {
  const address = process.env.WALLET_ADDRESS;

  const ContractFactory = await ethers.getContractFactory("Lock");
  const contract = await ContractFactory.deploy(address);

  console.log("Contract Deployed to Address:", contract.address);
}
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
