package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
)

func findCode(lines []string, keypad [][]rune) (code []rune) {
	max := len(keypad) - 1
	x, y := find5(keypad)

	for _, line := range lines {
		for _, char := range line {
			switch char {
			case 'L':
				x--
				if x < 0 || keypad[y][x] == 0 {
					x++
				}
			case 'R':
				x++
				if x > max || keypad[y][x] == 0 {
					x--
				}
			case 'U':
				y--
				if y < 0 || keypad[y][x] == 0 {
					y++
				}
			case 'D':
				y++
				if y > max || keypad[y][x] == 0 {
					y--
				}
			}

		}
		code = append(code, keypad[y][x])
	}

	return code
}

func find5(keypad [][]rune) (x, y int) {
	for y, row := range keypad {
		for x, char := range row {
			if char == '5' {
				return x, y
			}
		}
	}

	return -1, -1
}

func part1(lines []string) (code []rune) {
	var keypad = [][]rune{
		{'1', '2', '3'},
		{'4', '5', '6'},
		{'7', '8', '9'},
	}

	return findCode(lines, keypad)
}

func part2(lines []string) (code []rune) {
	var keypad = [][]rune{
		{0_0, 0_0, '1', 0_0, 0_0},
		{0_0, '2', '3', '4', 0_0},
		{'5', '6', '7', '8', '9'},
		{0_0, 'A', 'B', 'C', 0_0},
		{0_0, 0_0, 'D', 0_0, 0_0},
	}

	return findCode(lines, keypad)
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	lines := make([]string, 0)

	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	fmt.Print("Part 1: ")
	part1Code := part1(lines)
	fmt.Printf("%s\n", string(part1Code))

	fmt.Print("Part 2: ")
	part2Code := part2(lines)
	fmt.Printf("%s\n", string(part2Code))
}
