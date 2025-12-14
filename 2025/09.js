import { getInputLines, part1, part2 } from './aoc.js';

const tiles = (await getInputLines(2025, 9)).map((line) => {
  const [_, x, y] = line.match(/^(\d+),(\d+)$/);
  return { x: Number(x), y: Number(y) };
});

function area(tile1, tile2) {
  return (Math.abs(tile1.x - tile2.x) + 1) * (Math.abs(tile1.y - tile2.y) + 1);
}

const rectangles = [];
for (const [i, tile1] of tiles.entries()) {
  // Start at i+2 instead of i+1 to skip rectangles that are only one tile wide
  // or tall
  for (let j = i + 2; j < tiles.length; j++) {
    const tile2 = tiles[j];

    const rect = {
      xMin: Math.min(tile1.x, tile2.x),
      xMax: Math.max(tile1.x, tile2.x),
      yMin: Math.min(tile1.y, tile2.y),
      yMax: Math.max(tile1.y, tile2.y),
      area: area(tile1, tile2),
    };
    rectangles.push(rect);
  }
}
rectangles.sort((d1, d2) => d2.area - d1.area);
part1(rectangles[0].area);

const verticalLines = [];
const horizontalLines = [];

for (let i = 0; i < tiles.length; i++) {
  const tile1 = tiles[i];
  const tile2 = tiles[i + 1 < tiles.length ? i + 1 : 0];

  if (tile1.x === tile2.x) {
    verticalLines.push({
      x: tile1.x,
      yMin: Math.min(tile1.y, tile2.y),
      yMax: Math.max(tile1.y, tile2.y),
    });
  } else {
    horizontalLines.push({
      y: tile1.y,
      xMin: Math.min(tile1.x, tile2.x),
      xMax: Math.max(tile1.x, tile2.x),
    });
  }
}

verticalLines.sort((l1, l2) => l1.x - l2.x);
horizontalLines.sort((l1, l2) => l1.y - l2.y);

function isFilled(rectangle) {
  if (verticalLines.some((vert) => verticalIntersects(rectangle, vert))) {
    return false;
  }

  if (horizontalLines.some((hori) => horizontalIntersects(rectangle, hori))) {
    return false;
  }

  return centerIsGreen(rectangle);
}

function verticalIntersects(rectangle, vertical) {
  if (vertical.x <= rectangle.xMin) {
    // vertical is left of rectangle
    return false;
  }

  if (vertical.x >= rectangle.xMax) {
    // vertical is right of rectangle
    return false;
  }

  if (vertical.yMax <= rectangle.yMin) {
    // vertical is above rectangle
    return false;
  }

  if (vertical.yMin >= rectangle.yMax) {
    // vertical is below rectangle
    return false;
  }

  console.assert(
    (rectangle.yMin < vertical.yMax && vertical.yMax <= rectangle.yMax) ||
      (rectangle.yMin <= vertical.yMin && vertical.yMin < rectangle.yMax) ||
      (vertical.yMin <= rectangle.yMin && rectangle.yMax <= vertical.yMax),
    `vertical line ${vertical} doesn't intersect ${rectangle}`,
  );
  return true;
}

function horizontalIntersects(rectangle, horizontal) {
  if (horizontal.y <= rectangle.yMin) {
    // horizontal is above rectangle
    return false;
  }

  if (horizontal.y >= rectangle.yMax) {
    // horizontal is below rectangle
    return false;
  }

  if (horizontal.xMax <= rectangle.xMin) {
    // horizontal is left of rectangle
    return false;
  }

  if (horizontal.xMin >= rectangle.xMax) {
    // horizontal is right of rectangle
    return false;
  }

  console.assert(
    (rectangle.xMin < horizontal.xMax && horizontal.xMax <= rectangle.xMax) ||
      (rectangle.xMin <= horizontal.xMin && horizontal.xMin < rectangle.xMax) ||
      (horizontal.xMin <= rectangle.xMin && rectangle.xMax <= horizontal.xMax),
    `horizontal line ${horizontalMin} doesn't intersect ${rectangle}`,
  );
  return true;
}

// Confirm rectangle is filled with green tiles, instead of being an exterior
// concave corner
// https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm
function centerIsGreen(rectangle) {
  const xMid = Math.round((rectangle.xMin + rectangle.xMax) / 2);
  const yMid = Math.round((rectangle.yMin + rectangle.yMax) / 2);
  const horizontalCenterLine = {
    xMin: 0,
    xMax: xMid,
    yMin: yMid,
    yMax: yMid,
    area: 0,
  };

  let intersectCount = 0;
  for (const vertical of verticalLines) {
    if (verticalIntersects(horizontalCenterLine, vertical)) {
      intersectCount++;
    }
  }

  return intersectCount % 2 === 1;
}

part2(rectangles.find(isFilled).area);
