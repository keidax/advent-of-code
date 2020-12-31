package aoc

import (
	"bufio"
	"fmt"
	"os"
)

// Part1 outputs part 1 of the puzzle answer.
func Part1(answer ...interface{}) {
	fmt.Print("Part 1: ")
	fmt.Println(stringify(answer)...)
}

// Part2 outputs part 2 of the puzzle answer.
func Part2(answer ...interface{}) {
	fmt.Print("Part 2: ")
	fmt.Println(stringify(answer)...)
}

// stringify converts any byte or rune slices in the input into strings.
func stringify(vals []interface{}) []interface{} {
	stringVals := make([]interface{}, 0)

	for _, val := range vals {
		var stringVal interface{}

		switch val := val.(type) {
		case []byte:
			stringVal = string(val)
		case []rune:
			stringVal = string(val)
		default:
			stringVal = val
		}

		stringVals = append(stringVals, stringVal)
	}

	return stringVals
}

// InputLines returns the puzzle input as a slice of strings.
func InputLines() ([]string, error) {
	file, err := os.Open("input.txt")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lines := make([]string, 0)

	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return lines, nil
}

// InputBytes returns the puzzle input as a slice of byte slices.
func InputBytes() ([][]byte, error) {
	file, err := os.Open("input.txt")
	if err != nil {
		return nil, err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lines := make([][]byte, 0)

	for scanner.Scan() {
		// Make a copy of bytes, otherwise they may be overwritten
		scannedBytes := append([]byte{}, scanner.Bytes()...)
		lines = append(lines, scannedBytes)
	}

	if err := scanner.Err(); err != nil {
		return nil, err
	}

	return lines, nil
}
