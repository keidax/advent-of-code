import { getInputLines, part1, part2 } from './aoc.js';

const numberLines = (await getInputLines(2025, 6)).map((line) =>
  line.trim().split(/\s+/),
);
const operators = numberLines.pop();

function solveProblem(operator, numbers) {
  if (operator === '+') {
    return numbers.reduce((a, b) => a + Number(b), 0);
  } else {
    return numbers.reduce((a, b) => a * Number(b), 1);
  }
}

function transpose(grid) {
  const newGrid = grid[0].map(() => []);
  for (let rowIndex = 0; rowIndex < grid.length; rowIndex++) {
    for (let colIndex = 0; colIndex < grid[0].length; colIndex++) {
      newGrid[colIndex][rowIndex] = grid[rowIndex][colIndex];
    }
  }
  return newGrid;
}

let grandTotal = 0;
for (const [sym, ...numbers] of transpose([operators, ...numberLines])) {
  grandTotal += solveProblem(sym, numbers);
}
part1(grandTotal);

const digitGrid = (await getInputLines(2025, 6)).map((line) => [...line]);
digitGrid.pop(); // don't need operators

// Transpose the input and chunk into groups of vertical numbers per operator
const verticalNumbers = transpose(digitGrid).map((digits) =>
  Number(digits.join('')),
);
const verticalGroups = verticalNumbers.reduce(
  (acc, num) => {
    if (num === 0) {
      acc.push([]); // start a new group
    } else {
      acc.at(-1).push(num);
    }
    return acc;
  },
  [[]],
);

grandTotal = 0;
for (const [i, sym] of operators.entries()) {
  grandTotal += solveProblem(sym, verticalGroups[i]);
}
part2(grandTotal);
