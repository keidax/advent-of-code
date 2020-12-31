package main

import (
	"github.com/keidax/advent-of-code/aoc"
)

func tallyChars(input [][]byte) []map[byte]int {
	tally := make([]map[byte]int, 0)

	for i := 0; i < len(input[0]); i++ {
		tally = append(tally, make(map[byte]int))
	}

	for _, line := range input {
		for i, char := range line {
			tally[i][char]++
		}
	}

	return tally
}

func mostCommonChars(tally []map[byte]int) []byte {
	output := make([]byte, len(tally))

	for i, chars := range tally {
		maxCount := 0
		maxChar := byte(0)

		for char, count := range chars {
			if count > maxCount {
				maxCount = count
				maxChar = char
			}
		}

		output[i] = maxChar
	}

	return output
}

func leastCommonChars(tally []map[byte]int) []byte {
	output := make([]byte, len(tally))

	for i, chars := range tally {
		minCount := 9999
		minChar := byte(0)

		for char, count := range chars {
			if count < minCount {
				minCount = count
				minChar = char
			}
		}

		output[i] = minChar
	}

	return output
}

func main() {
	lines, err := aoc.InputBytes()
	if err != nil {
		panic(err)
	}

	charCounts := tallyChars(lines)

	aoc.Part1(mostCommonChars(charCounts))
	aoc.Part2(leastCommonChars(charCounts))
}
