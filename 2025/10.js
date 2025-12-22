import { getInputLines, part1, part2 } from './aoc.js';

// Part 2 is relatively brute-force with optimizations. It runs in 80-90 seconds
// on my machine.

class Machine {
  constructor(line) {
    const [_, desiredLights] = line.match(/\[([.#]+)\]/);
    this.desiredState = [...desiredLights].reduce((acc, char, index) => {
      if (char === '#') {
        return acc + (1 << index);
      } else {
        return acc;
      }
    }, 0);

    this.buttons = [];
    for (const [_, buttonMatch] of line.matchAll(/\((\d(,\d)*)\)/g)) {
      this.buttons.push(
        buttonMatch.split(',').reduce((acc, digit) => acc + (1 << digit), 0),
      );
    }

    this.buttonJolts = this.buttons.map((button) => {
      const jolts = [];
      for (let i = 0; i < desiredLights.length; i++) {
        if (button & (1 << i)) {
          jolts.push(i);
        }
      }
      return jolts;
    });

    const [__, jolts] = line.match(/\{(\d+(,\d+)*)\}/);
    this.desiredJoltage = jolts.split(',').map(Number);
  }

  fewestPresses() {
    const pastStates = new Set();
    const initialState = { state: 0, presses: 0 };
    const queue = [initialState];

    while (queue.length > 0) {
      const { presses, state } = queue.shift();

      if (pastStates.has(state)) {
        continue;
      }
      pastStates.add(state);

      for (const button of this.buttons) {
        const newState = state ^ button;

        if (newState === this.desiredState) {
          return presses + 1;
        }

        queue.push({
          state: newState,
          presses: presses + 1,
        });
      }
    }
  }

  // This is a recursive DFS with a bunch of optimizations thrown in. The
  // function returns null if a solution is not possible for the inputs.
  fewestJoltPresses(
    remainingJoltage = this.desiredJoltage.slice(0),
    // Sort buttons at the beginning so that larger buttons are always tried
    // first. Larger buttons are more "efficient" -- more total jolts per press,
    // so fewer presses overall.
    buttonJolts = this.buttonJolts.slice(0).sort((a, b) => b.length - a.length),
    bestSoFar = Number.MAX_SAFE_INTEGER,
  ) {
    if (remainingJoltage.every((j) => j === 0)) {
      // The end case -- we've reached the right joltage levels.
      return 0;
    }

    if (buttonJolts.length < 1) {
      // We haven't reached the right joltage levels, but there's no buttons
      // left to push
      return null;
    }

    // The strategy here is to find the joltage counter that is affected by the
    // fewest number of buttons. Fewer permutations of buttons to try means we
    // can narrow down the search tree faster.
    let smallestButtonGrouping = null;

    for (let i = 0; i < remainingJoltage.length; i++) {
      if (remainingJoltage[i] >= bestSoFar) {
        // We can't improve on the current lower bound by searching further.
        return null;
      }
      if (remainingJoltage[i] === 0) {
        continue;
      }

      const possibleButtons = [];
      for (let j = 0; j < buttonJolts.length; j++) {
        const button = buttonJolts[j];
        if (button.includes(i)) {
          possibleButtons.push(button);
        }
      }

      if (possibleButtons.length === 0) {
        // There are no buttons left that could affect this counter.
        return null;
      }

      if (possibleButtons.length === 1) {
        // There's exactly one button that could affect this counter, so we know
        // exactly how many times it must be pressed.
        const [button] = possibleButtons;
        const buttonsAfterPress = buttonJolts.filter((b) => b !== button);
        const presses = remainingJoltage[i];
        const joltageAfterPress = remainingJoltage.slice();

        for (let j = 0; j < button.length; j++) {
          joltageAfterPress[button[j]] -= presses;
          if (joltageAfterPress[button[j]] < 0) {
            // We've overflowed one of the counters that this button affects.
            return null;
          }
        }

        const result = this.fewestJoltPresses(
          joltageAfterPress,
          buttonsAfterPress,
          bestSoFar - presses,
        );

        if (result === null) {
          return result;
        }

        return presses + result;
      }

      if (smallestButtonGrouping === null) {
        smallestButtonGrouping = possibleButtons;
      } else if (possibleButtons.length < smallestButtonGrouping.length) {
        smallestButtonGrouping = possibleButtons;
      }
    }

    // smallestButtonGrouping should already be sorted. We now have the next
    // optimal button to test.
    const nextButtonToTry = smallestButtonGrouping.at(0);
    const buttonsAfterPress = buttonJolts.filter((b) => b !== nextButtonToTry);

    let maxPresses = remainingJoltage[nextButtonToTry[0]];
    for (let i = 1; i < nextButtonToTry.length; i++) {
      maxPresses = Math.min(maxPresses, remainingJoltage[nextButtonToTry[i]]);
    }

    let minResult = null;

    // Try pressing our optimal button as many times as possible first. This
    // means we can find a lower bound faster, and skip later checks.
    for (let presses = maxPresses; presses >= 0; presses--) {
      const joltageAfterPress = remainingJoltage.slice();
      for (let i = 0; i < nextButtonToTry.length; i++) {
        joltageAfterPress[nextButtonToTry[i]] -= presses;
      }

      const result = this.fewestJoltPresses(
        joltageAfterPress,
        buttonsAfterPress,
        bestSoFar - presses,
      );

      if (result === null) {
        continue;
      }

      if (minResult === null) {
        minResult = result + presses;
      } else {
        minResult = Math.min(minResult, result + presses);
      }
      bestSoFar = minResult;
    }

    return minResult;
  }
}

const machines = (await getInputLines(2025, 10)).map(
  (line) => new Machine(line),
);

part1(machines.map((m) => m.fewestPresses()).reduce((a, b) => a + b));
part2(machines.map((m, i, a) => m.fewestJoltPresses()).reduce((a, b) => a + b));
