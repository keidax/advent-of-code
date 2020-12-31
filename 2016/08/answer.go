package main

import (
	"fmt"
	"regexp"
	"strconv"

	"github.com/keidax/advent-of-code/aoc"
)

const (
	rowSize    = 50
	columnSize = 6
)

func extractNums(re *regexp.Regexp, s string) ([]int, error) {
	match := re.FindStringSubmatch(s)
	nums := make([]int, 0)

	for i := 1; i < len(match); i++ {
		num, err := strconv.Atoi(match[i])
		if err != nil {
			return nums, err
		}
		nums = append(nums, num)

	}

	return nums, nil
}

func operateScreen(input []string) (screen [columnSize][rowSize]bool, err error) {
	rectRe := regexp.MustCompile("rect ([0-9]+)x([0-9]+)")
	rowRe := regexp.MustCompile("rotate row y=([0-9]+) by ([0-9]+)")
	columnRe := regexp.MustCompile("rotate column x=([0-9]+) by ([0-9]+)")

	for _, line := range input {
		switch {
		case rectRe.MatchString(line):
			match, err := extractNums(rectRe, line)
			if err != nil {
				return screen, err
			}
			width, height := match[0], match[1]

			for x := 0; x < width; x++ {
				for y := 0; y < height; y++ {
					screen[y][x] = true
				}
			}
		case rowRe.MatchString(line):
			match, err := extractNums(rowRe, line)
			if err != nil {
				return screen, err
			}
			y, offset := match[0], match[1]

			row := make([]bool, rowSize)
			for x := 0; x < rowSize; x++ {
				row[x] = screen[y][x]
			}

			shiftedRow := append(row[rowSize-offset:], row[0:rowSize-offset]...)

			for x := 0; x < rowSize; x++ {
				screen[y][x] = shiftedRow[x]
			}
		case columnRe.MatchString(line):
			match, err := extractNums(columnRe, line)
			if err != nil {
				return screen, err
			}
			x, offset := match[0], match[1]

			column := make([]bool, columnSize)
			for y := 0; y < columnSize; y++ {
				column[y] = screen[y][x]
			}

			shiftedColumn := append(column[columnSize-offset:], column[0:columnSize-offset]...)

			for y := 0; y < columnSize; y++ {
				screen[y][x] = shiftedColumn[y]
			}
		}
	}

	return
}

func countPixels(screen [columnSize][rowSize]bool) (count int) {
	for _, row := range screen {
		for _, pixel := range row {
			if pixel {
				count++
			}
		}
	}

	return
}

func printScreen(screen [columnSize][rowSize]bool) {
	for _, row := range screen {
		for _, pixel := range row {
			var char rune
			if pixel {
				char = '█'
			} else {
				char = '░'
			}
			fmt.Printf("%c", char)
		}
		fmt.Println()
	}
}

func main() {
	lines, err := aoc.InputLines()
	if err != nil {
		panic(err)
	}

	screen, err := operateScreen(lines)
	if err != nil {
		panic(err)
	}

	aoc.Part1(countPixels(screen))
	aoc.Part2()
	printScreen(screen)
}
