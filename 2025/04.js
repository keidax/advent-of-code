import { getInputLines, part1, part2 } from './aoc.js';

const offsets = [
  [0, 1],
  [1, 1],
  [1, 0],
  [1, -1],
  [0, -1],
  [-1, -1],
  [-1, 0],
  [-1, 1],
];

const grid = (await getInputLines(2025, 4)).map((line) => [...line]);

// Keep track of just the valid roll coordinates
const rolls = new Set();
// Holds a count of how many rolls are adjacent to each tile
const adjacentCounts = grid.map((row) => new Array(row.length).fill(0));

function inBounds(row, col) {
  if (row < 0 || col < 0) {
    return false;
  }
  if (row >= grid.length || col >= grid[row].length) {
    return false;
  }
  return true;
}

// Yield all valid neighboring tiles
function* neighbors(row, col) {
  for (const [rowOff, colOff] of offsets) {
    const adjRow = row + rowOff;
    const adjCol = col + colOff;
    if (inBounds(adjRow, adjCol)) {
      yield [adjRow, adjCol];
    }
  }
}

for (let row = 0; row < grid.length; row++) {
  for (let col = 0; col < grid[row].length; col++) {
    if (grid[row][col] === '@') {
      // Add the roll and increment all neighboring tiles
      rolls.add([row, col]);
      for (const [adjRow, adjCol] of neighbors(row, col)) {
        adjacentCounts[adjRow][adjCol]++;
      }
    }
  }
}

let rollCount = 0;
for (const [row, col] of rolls) {
  if (adjacentCounts[row][col] < 4) {
    rollCount++;
  }
}
part1(rollCount);

let removed = 0;
let totalRemoved = 0;

do {
  removed = 0;
  for (const roll of rolls) {
    const [row, col] = roll;
    if (adjacentCounts[row][col] < 4) {
      // Remove the roll and decrement all neighboring tiles
      for (const [adjRow, adjCol] of neighbors(row, col)) {
        adjacentCounts[adjRow][adjCol]--;
      }
      rolls.delete(roll);
      removed++;
    }
  }

  totalRemoved += removed;
} while (removed > 0);
part2(totalRemoved);
