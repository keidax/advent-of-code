import { getInputLines, part1, part2 } from './aoc.js';

const beamGrid = (await getInputLines(2025, 7)).map((line) => [...line]);

// splitters is a map containing all the splitters in the manifold. Keys are x
// coordinates for the splitters. Values are lists of y coordinates in sorted
// order.
const splitters = new Map();
// activatedSplitters is a map containing all splitters that a beam has passed
// through. Keys are the same as splitters, values are sets of y coordinates.
const activatedSplitters = new Map();

let start = null;
for (let y = 0; y < beamGrid.length; y++) {
  for (let x = 0; x < beamGrid[y].length; x++) {
    switch (beamGrid[y][x]) {
      case 'S':
        start = { x, y };
        break;
      case '^':
        if (!splitters.has(x)) {
          splitters.set(x, []);
        }
        splitters.get(x).push(y);
        break;
    }
  }
}

// Given a beam as an x-y coordinate, trace the beam down until it passes
// through a splitter, or exits the manifold
function findSplitterForBeam({ x, y }) {
  const splittersInColumn = splitters.get(x);
  if (!splittersInColumn) {
    return null;
  }

  for (const splitterY of splittersInColumn) {
    // This assumes y values are sorted
    if (splitterY > y) {
      return { x, y: splitterY };
    }
  }
  return null;
}

// Mark the given splitter to the activated set (idempotent)
function addToActivated({ x, y }) {
  if (activatedSplitters.has(x)) {
    activatedSplitters.get(x).add(y);
  } else {
    activatedSplitters.set(x, new Set([y]));
  }
}

// beamStarts is a map from beam start coordinates to the number of paths for
// the beam. Objects will not work as map keys (they're compared by reference
// instead of structurally) so beam coords are converted to JSON.
const beamStarts = new Map([[JSON.stringify(start), 1]]);

// Add a beam start to the map. If another beam start already exists in this
// location, their path counts are combined
function upsertBeamStart({ x, y }, paths) {
  const key = JSON.stringify({ x, y });
  if (beamStarts.has(key)) {
    beamStarts.set(key, beamStarts.get(key) + paths);
  } else {
    beamStarts.set(key, paths);
  }
}

// The general idea is to do a breadth-first iteration of each splitter that
// gets activated. Rely on the fact that map entries are sorted by insertion
// order to iterate the beam start positions from top to bottom, and left to
// right.
let totalPaths = 0;
while (beamStarts.size > 0) {
  const [beamStartKey, paths] = beamStarts.entries().next().value;
  beamStarts.delete(beamStartKey);
  const beamStart = JSON.parse(beamStartKey);

  const nextSplitter = findSplitterForBeam(beamStart);
  if (!nextSplitter) {
    // exiting the bottom of the manifold
    totalPaths += paths;
    continue;
  }

  const { x, y } = nextSplitter;
  upsertBeamStart({ x: x - 1, y }, paths);
  upsertBeamStart({ x: x + 1, y }, paths);
  addToActivated(nextSplitter);
}

part1(activatedSplitters.values().reduce((acc, yVals) => acc + yVals.size, 0));
part2(totalPaths);
