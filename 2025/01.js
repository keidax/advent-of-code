import { getInputLines, part1, part2 } from './aoc.js';

let dial = 50;
let stopZeroCount = 0;
let anyZeroCount = 0;
const r = /([LR])(\d+)/;

for (const line of await getInputLines(2025, 1)) {
  const [_, direction, turnStr] = line.match(r);
  let turn = Number(turnStr);

  // Check full rotations
  if (turn >= 100) {
    anyZeroCount += Math.floor(turn / 100);
    turn %= 100;
  }

  if (direction === 'L') {
    if (turn >= dial && dial !== 0) {
      // Left rotation stops on or passes 0
      anyZeroCount++;
    }
    dial -= turn;
  } else {
    if (dial !== 0 && turn + dial >= 100) {
      // Right rotation stops on or passes 0
      anyZeroCount++;
    }
    dial += turn;
  }

  // Make sure dial is normalized as non-negative
  dial = ((dial % 100) + 100) % 100;

  if (dial === 0) {
    stopZeroCount++;
  }
}

part1(stopZeroCount);
part2(anyZeroCount);
