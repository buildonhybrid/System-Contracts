import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// (1)
const values = [
  ["0x7baBf95621f22bEf2DB67E500D022Ca110722FaD", "3"],
  ["0x897cFb719F4d0D390E51564AE318239aa9d2F938", "2"],
  ["0xEADe658C09c3d151A83bDf4873433B4a70530D93", "4"],
];

// (2)
const tree = StandardMerkleTree.of(values, ["address", "uint256"]);

// (3)
console.log('Merkle Root:', tree.root);

// (4)
fs.writeFileSync("tree.json", JSON.stringify(tree.dump()));