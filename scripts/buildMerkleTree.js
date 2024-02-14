const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

var data;

fs.readFile("WhitelistedUsers.json", "utf8", (err, jsonData) => {
  if (err) {
    console.error("Error reading JSON file:", err);
    return;
  }
  data = JSON.parse(jsonData);
  // console.log("Parsed DATA: \n", data);

  // Generating Merkle tree with data
  const tree = StandardMerkleTree.of(data, ["address", "uint256"]);

  console.log("Merkle Root:", tree.root);
  fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));
});
