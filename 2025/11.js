import { getInputLines, part1, part2 } from './aoc.js';

class Device {
  constructor(label, outLabels) {
    this.label = label;
    this.outs = outLabels.split(' ');
    this.paths = 0;
    this.connections = 0;
  }
}

const network = new Map();

(await getInputLines(2025, 11)).map((line) => {
  const [deviceLabel, outs] = line.split(': ');
  network.set(deviceLabel, new Device(deviceLabel, outs));
});

// Add `out` to the network
const outDevice = new Device('out', '');
outDevice.outs = [];
network.set('out', outDevice);

// Count the number of paths between 2 nodes on the network. This works in two
// phases. First, traverse through the whole graph and count how many *inbound*
// connections each node has. Second, traverse again while counting paths from
// the source. On the second phase, make sure we only visit nodes *after* all
// inbound nodes have been visited.
function pathCount(start, finish) {
  for (const device of network.values()) {
    device.paths = 0;
    device.connections = 0;
  }

  const startingDevice = network.get(start);
  startingDevice.paths = 1;
  const queue = [startingDevice];
  const visited = new Set();

  while (queue.length > 0) {
    const nextDevice = queue.shift();

    if (visited.has(nextDevice.label)) {
      continue;
    }

    visited.add(nextDevice.label);

    for (const out of nextDevice.outs) {
      const connectedDevice = network.get(out);
      if (!connectedDevice) {
        continue;
      }
      connectedDevice.connections++;
      queue.push(connectedDevice);
    }
  }

  visited.clear();
  queue.push(startingDevice);

  while (queue.length > 0) {
    if (queue[0].connections !== 0) {
      queue.sort((a, b) => a.connections - b.connections);
    }

    const nextDevice = queue.shift();
    console.assert(
      nextDevice.connections === 0,
      `device ${nextDevice.label} has ${nextDevice.connections} connections`,
    );

    if (nextDevice.label === finish) {
      return nextDevice.paths;
    }

    if (visited.has(nextDevice.label)) {
      continue;
    }

    visited.add(nextDevice.label);

    for (const out of nextDevice.outs) {
      const connectedDevice = network.get(out);
      if (!connectedDevice) {
        continue;
      }
      connectedDevice.connections--;
      connectedDevice.paths += nextDevice.paths;
      queue.push(connectedDevice);
    }
  }

  // Catch-all return in case we couldn't find a path between start and finish.
  return network.get(finish).paths;
}

part1(pathCount('you', 'out'));

const dac2fft = pathCount('dac', 'fft');
const fft2dac = pathCount('fft', 'dac');
const [earlier, later] = dac2fft > fft2dac ? ['dac', 'fft'] : ['fft', 'dac'];
const firstSeg = pathCount('svr', earlier);
const lastSeg = pathCount(later, 'out');

part2(firstSeg * Math.max(dac2fft, fft2dac) * lastSeg);
