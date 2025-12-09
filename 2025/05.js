import { getInputLines, part1, part2 } from './aoc.js';

const database = await getInputLines(2025, 5);
const separator = database.indexOf('');

const freshRanges = database
  .slice(0, separator)
  .map((range) => range.split('-').map((num) => Number(num)));

const ingredientIds = database
  .slice(separator + 1)
  .map((ingredient) => Number(ingredient));

for (const [min, max] of freshRanges) {
  console.assert(max < Number.MAX_SAFE_INTEGER, 'range is too large');
}

let freshCount = 0;
for (const ingredient of ingredientIds) {
  for (const [min, max] of freshRanges) {
    if (min <= ingredient && ingredient <= max) {
      freshCount++;
      break;
    }
  }
}
part1(freshCount);

function isOverlap([min1, max1], [min2, max2]) {
  if (min1 <= min2 && min2 <= max1) {
    return true; // range 1 is before range 2
  }

  if (min2 <= min1 && min1 <= max2) {
    return true; // range 2 is before range 1
  }

  return false; // no overlap
}

function combineRanges([min1, max1], [min2, max2]) {
  return [Math.min(min1, min2), Math.max(max1, max2)];
}

function mergeRange(ranges, newRange) {
  for (const [i, otherRange] of ranges.entries()) {
    if (isOverlap(newRange, otherRange)) {
      ranges.splice(i, 1);
      newRange = combineRanges(newRange, otherRange);
      // newRange might overlap with other ranges in the set. Recursively grow
      // and merge until there are no more overlaps.
      return mergeRange(ranges, newRange);
    }
  }

  ranges.push(newRange);
}

const mergedRanges = [];
for (const range of freshRanges) {
  merge(mergedRanges, range);
}

let freshIdCount = 0;
for (const [min, max] of mergedRanges) {
  freshIdCount += max - min + 1;
  console.assert(freshIdCount < Number.MAX_SAFE_INTEGER, 'answer is too large');
}
part2(freshIdCount);
