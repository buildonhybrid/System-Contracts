import { StandardMerkleTree } from "@openzeppelin/merkle-tree";
import fs from "fs";

// (1)
const values = [
  ["0x7baBf95621f22bEf2DB67E500D022Ca110722FaD", "3"],
  ["0x897cFb719F4d0D390E51564AE318239aa9d2F938", "2"],
  ["0xEADe658C09c3d151A83bDf4873433B4a70530D93", "4"],
];

// (1)
const valuesTest = [
  ["1", "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6", "3"],
  ["2", "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6", "3"],
  ["3", "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6", "3"],
  ["4", "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6", "3"],
  ["5", "0x328809Bc894f92807417D2dAD6b7C998c1aFdac6", "3"],
  ["1", "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e", "2"],
  ["2", "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e", "2"],
  ["3", "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e", "2"],
  ["4", "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e", "2"],
  ["5", "0x1D96F2f6BeF1202E4Ce1Ff6Dad0c2CB002861d3e", "2"],
  ["1", "0xA4d4c1f8a763Ef6a0140D04291eCEef913Ffc272", "4"],
  ["2", "0xA4d4c1f8a763Ef6a0140D04291eCEef913Ffc272", "4"],
  ["3", "0xA4d4c1f8a763Ef6a0140D04291eCEef913Ffc272", "4"],
  ["4", "0xA4d4c1f8a763Ef6a0140D04291eCEef913Ffc272", "4"],
  ["5", "0xA4d4c1f8a763Ef6a0140D04291eCEef913Ffc272", "4"],
];

// (2)
const tree = StandardMerkleTree.of(valuesTest, ["uint8", "address", "uint256"]);

// (3)
console.log('Merkle Root:', tree.root);

// (4)
fs.writeFileSync("treeFoundry.json", JSON.stringify(tree.dump()));