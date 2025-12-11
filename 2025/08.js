import { getInputLines, part1, part2 } from './aoc.js';

const junctionBoxes = (await getInputLines(2025, 8)).map((line) => {
  const [_, xStr, yStr, zStr] = line.match(/^(\d+),(\d+),(\d+)$/);
  return { x: Number(xStr), y: Number(yStr), z: Number(zStr) };
});

function distance(box1, box2) {
  return Math.sqrt(
    (box1.x - box2.x) ** 2 + (box1.y - box2.y) ** 2 + (box1.z - box2.z) ** 2,
  );
}

const distancePairs = [];
for (const [i, box1] of junctionBoxes.entries()) {
  for (let j = i + 1; j < junctionBoxes.length; j++) {
    const box2 = junctionBoxes[j];
    distancePairs.push([distance(box1, box2), box1, box2]);
  }
}
distancePairs.sort(([d1], [d2]) => d1 - d2);

const boxToCircuit = new Map(junctionBoxes.map((jb) => [jb, new Set([jb])]));

function makeNextConnection(pair) {
  const [_distance, box1, box2] = pair;
  const circuit1 = boxToCircuit.get(box1);
  const circuit2 = boxToCircuit.get(box2);

  if (circuit1 === circuit2) {
    return circuit1;
  }

  for (const box of circuit2) {
    circuit1.add(box);
    boxToCircuit.set(box, circuit1);
  }

  return circuit1;
}

for (let i = 0; i < 1000; i++) {
  makeNextConnection(distancePairs[i]);
}

const uniqueCircuits = new Set(boxToCircuit.values());
part1(
  uniqueCircuits
    .values()
    .map((c) => c.size)
    .toArray()
    .sort((a, b) => b - a)
    .slice(0, 3)
    .reduce((acc, val) => acc * val, 1),
);

let lastPair = null;
for (let i = 1000; i < distancePairs.length; i++) {
  const pair = distancePairs[i];
  const circuit = makeNextConnection(pair);
  if (circuit.size === junctionBoxes.length) {
    lastPair = pair;
    break;
  }
}

part2(lastPair[1].x * lastPair[2].x);
