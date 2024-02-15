const { StandardMerkleTree } = require("@openzeppelin/merkle-tree");
const fs = require("fs");

var data;
const jsonFile = "MockUserData.json"; //  for mock users
// const jsonFile = "WhitelistedUsers.json"; // for actual users
fs.readFile(jsonFile, "utf8", (err, jsonData) => {
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
