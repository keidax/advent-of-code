import fs from 'node:fs/promises';
import https from 'node:https';
import process from 'node:process';

async function getInput(year, day) {
  const formattedDay = String(day).padStart(2, '0');
  const dataFile = `${formattedDay}_input.txt`;

  try {
    await fs.access(dataFile, fs.constants.R_OK);
  } catch {
    await httpsGetPromise(
      `https://adventofcode.com/${year}/day/${day}/input`,
      {
        headers: {
          Cookie: `session=${process.env['AOC_SESSION']}`,
        },
      },
      dataFile,
    );
  }
  return fs.open(dataFile, 'r');
}

async function getInputLines(year, day, lineHandler) {
  const input = await getInput(year, day);
  const rl = input.readLines();
  const lines = [];
  return new Promise((resolve) => {
    rl.on('line', (line) => lines.push(line));
    rl.on('close', () => resolve(lines));
  });
}

function httpsGetPromise(url, options, fileName) {
  return new Promise((resolve, reject) => {
    console.log('Downloading from', url);
    const request = https.get(url, options);

    request.on('error', (err) => {
      reject(err);
    });

    request.on('response', (response) => {
      let rawData = '';
      response.on('data', (chunk) => {
        rawData += chunk;
      });

      if (response.statusCode === 200) {
        response.on('end', async () => {
          await fs.writeFile(fileName, rawData);
          resolve();
        });
      } else {
        response.on('end', () => {
          reject(
            new Error('statusCode = ' + response.statusCode + '\n' + rawData),
          );
        });
      }
    });

    request.end();
  });
}

function part(num, result) {
  console.log(`❄️ part ${num}: ${result}`);
}
function part1(result) {
  part(1, result);
}
function part2(result) {
  part(2, result);
}

export { getInput, getInputLines, part1, part2 };
