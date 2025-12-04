import { getInputLines, part1, part2 } from './aoc.js';

function maxDigitInRange(batteries, start, end) {
  for (let jolt = 9; jolt > 0; jolt--) {
    const joltIndex = batteries.indexOf(jolt, start);
    if (joltIndex !== -1 && joltIndex < end) {
      return joltIndex;
    }
  }
}

// A greedy algorithm that finds the highest digit one place at a time
function maximumJoltage(batteries, size) {
  const batteryIndexes = [];

  for (let i = 0; i < size; i++) {
    const startOfSearch = i === 0 ? 0 : batteryIndexes.at(-1) + 1;
    const endOfSearch = batteries.length - size + i + 1;
    const nextIndex = maxDigitInRange(batteries, startOfSearch, endOfSearch);
    batteryIndexes.push(nextIndex);
  }

  return batteryIndexes.reduce(
    (acc, batteryIndex) => acc * 10 + batteries[batteryIndex],
    0,
  );
}

const batteryBanks = (await getInputLines(2025, 3)).map((line) =>
  [...line].map((char) => Number(char)),
);
part1(
  batteryBanks.map((bat) => maximumJoltage(bat, 2)).reduce((a, b) => a + b),
);
part2(
  batteryBanks.map((bat) => maximumJoltage(bat, 12)).reduce((a, b) => a + b),
);
