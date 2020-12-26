package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
)

func countTriangles(numbers [][]int) (count int) {
	for _, nums := range numbers {
		if nums[0]+nums[1] > nums[2] {
			count++
		}
	}

	return count
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	rowNum := 0

	numbers := make([][]int, 0)
	numbers2 := make([][]int, 0)

	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)

		numbers = append(numbers, make([]int, 0))
		if rowNum%3 == 0 {
			numbers2 = append(numbers2, make([]int, 0))
			numbers2 = append(numbers2, make([]int, 0))
			numbers2 = append(numbers2, make([]int, 0))
		}

		rowOff := (rowNum / 3) * 3

		for i, field := range fields {
			num, err := strconv.Atoi(field)
			if err != nil {
				log.Fatal(err)
			}

			numbers[rowNum] = append(numbers[rowNum], num)
			numbers2[rowOff+i] = append(numbers2[rowOff+i], num)
		}

		sort.Ints(numbers[rowNum])
		if rowNum%3 == 2 {
			sort.Ints(numbers2[rowOff])
			sort.Ints(numbers2[rowOff+1])
			sort.Ints(numbers2[rowOff+2])
		}

		rowNum++
	}

	fmt.Printf("Part 1: %d\n", countTriangles(numbers))
	fmt.Printf("Part 1: %d\n", countTriangles(numbers2))
}
