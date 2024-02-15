const { ethers } = require("hardhat");
const fs = require("fs");

function generateRandomAddress() {
  const wallet = ethers.Wallet.createRandom();
  return wallet.address;
}

function generateRandomValue() {
  // Generate a random integer between 1 and 10 (inclusive)
  const randomInteger = Math.floor(Math.random() * 10) + 1;
  // Convert the random integer to Wei
  return ethers.parseEther(randomInteger.toString());
}

function generateRandomJson(numEntries) {
  const json = [];
  let sumOfAmount = BigInt(0);
  for (let i = 0; i < numEntries; i++) {
    const address = generateRandomAddress();
    const value = generateRandomValue();
    json.push([address, value.toString()]);
    sumOfAmount += BigInt(value);
  }
  console.log(`**************** SUM OF AMOUNT *************: ${sumOfAmount}`);
  console.log(`**************** SUM OF AMOUNT (in ETHs) *************: ${ethers.formatEther(sumOfAmount)}`);
  return json;
}

const NUMBER_OF_USERS = 10;
const json = generateRandomJson(NUMBER_OF_USERS);

const fileName = "MockUserData.json";
fs.writeFileSync(fileName, JSON.stringify(json, null, 2));
console.log(`Generated JSON written to ${fileName}`);
