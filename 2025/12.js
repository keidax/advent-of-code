import { getInputLines, part1, part2 } from './aoc.js';

const shapeSections = (await getInputLines(2025, 12)).reduce(
  // chunk input by blank lines
  (acc, line) => {
    if (line === '') {
      acc.push([]);
    } else {
      acc.at(-1).push(line);
    }
    return acc;
  },
  [[]],
);

const regionLines = shapeSections.pop();
const regions = regionLines.map((line) => {
  const [_, width, height, countString] = line.match(/(\d+)x(\d+): (.*)/);
  const counts = countString.split(' ').map(Number);

  return { width, height, counts };
});

const shapeAreas = shapeSections.map((lines) => {
  lines.shift(); // don't need the index
  let area = 0;
  for (const line of lines) {
    for (const char of line) {
      if (char === '#') {
        area += 1;
      }
    }
  }
  return area;
});

let [definiteFit, definiteNoFit, maybeFit] = [0, 0, 0];

// Find regions that can be trivially packed with presents (by treating each
// present as a 3x3 square), and regions where presents cannot possibly fit
// (total area of presents is greater than the region).
for (const region of regions) {
  const area = region.width * region.height;
  const requiredShapeArea = region.counts.reduce((acc, count, shapeIndex) => {
    return acc + count * shapeAreas[shapeIndex];
  }, 0);

  if (requiredShapeArea > area) {
    definiteNoFit++;
    continue;
  }

  const easyShapeCount =
    Math.floor(region.width / 3) * Math.floor(region.height / 3);
  const shapeCount = region.counts.reduce((a, b) => a + b);

  if (shapeCount <= easyShapeCount) {
    definiteFit++;
  } else {
    maybeFit++;
  }
}

console.assert(
  maybeFit === 0,
  `${maybeFit} regions could not be trivially solved`,
);

part1(definiteFit);
