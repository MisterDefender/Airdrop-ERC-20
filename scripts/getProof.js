const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

const getProofFroAccount = "0x2222222222222222222222222222222222222222";

async function getProof(accountAddress) {
  const tree = StandardMerkleTree.load(
    JSON.parse(fs.readFileSync("tree.json", "utf8"))
  );
  for (const [i, v] of tree.entries()) {
    if (v[0] === accountAddress) {
      const proof = tree.getProof(i);
      console.log("Value:", v);
      console.log("Proof:", proof);
    }
  }
}

getProof(getProofFroAccount)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
