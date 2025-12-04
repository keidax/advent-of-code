import { getInputLines, part1, part2 } from './aoc.js';

class IdRange {
  constructor(rangeStr) {
    const [start, end] = rangeStr.split('-');
    this.start = start;
    this.end = end;
  }

  *invalidIds(repeatCount) {
    let len = this.start.length;
    let firstSegment = null;
    if (len % repeatCount == 0) {
      firstSegment = this.start.slice(0, len / repeatCount);
    } else {
      // A number with digit count that doesn't divide evenly by `repeats` can
      // never be invalid -- round up to the next possible number.
      len = Math.ceil(len / repeatCount) * repeatCount;
      firstSegment = '1' + '0'.repeat(len / repeatCount - 1);
    }

    let id = Number(firstSegment.repeat(repeatCount));

    if (id < Number(this.start)) {
      // The remaining segments of the starting number are greater than the
      // first segment, so we need to increment the first segment.
      firstSegment = String(Number(firstSegment) + 1);
      id = Number(firstSegment.repeat(repeatCount));
    }

    while (id <= Number(this.end)) {
      yield id;
      firstSegment = String(Number(firstSegment) + 1);
      id = Number(firstSegment.repeat(repeatCount));
    }
  }

  invalidIdsAll() {
    const idSet = new Set();

    for (let repeatCount = 2; repeatCount <= this.end.length; repeatCount++) {
      for (const id of this.invalidIds(repeatCount)) {
        idSet.add(id);
      }
    }

    return idSet.values();
  }
}

const [idRangeList] = await getInputLines(2025, 2);
const idRanges = idRangeList.split(',').map((str) => new IdRange(str));

part1(
  idRanges.flatMap((range) => [...range.invalidIds(2)]).reduce((a, b) => a + b),
);

part2(
  idRanges
    .flatMap((range) => [...range.invalidIdsAll()])
    .reduce((a, b) => a + b),
);
