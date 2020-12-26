package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"regexp"
	"strconv"
	"strings"
)

func distance(x, y int) (distance int) {
	if x < 0 {
		x = -x
	}

	if y < 0 {
		y = -y
	}

	return x + y
}

func part1(instructions []string) (int, error) {
	direction := 90
	x, y := 0, 0

	for _, t := range instructions {
		if t[0] == 'R' {
			direction -= 90
		} else if t[0] == 'L' {
			direction += 90
		}

		if direction < 0 {
			direction += 360
		}

		direction %= 360

		dist, err := strconv.Atoi(t[1:])
		if err != nil {
			return 0, err
		}

		switch direction {
		case 0:
			x += dist
		case 90:
			y += dist
		case 180:
			x -= dist
		case 270:
			y -= dist
		}

	}

	return distance(x, y), nil
}

func part2(instructions []string) (int, error) {

	direction := 90
	x, y := 0, 0

	visited := make(map[[2]int]bool)
	visited[[2]int{0, 0}] = true

	for _, t := range instructions {
		if t[0] == 'R' {
			direction -= 90
		} else if t[0] == 'L' {
			direction += 90
		}

		if direction < 0 {
			direction += 360
		}

		direction %= 360

		dist, err := strconv.Atoi(t[1:])
		if err != nil {
			return 0, err
		}

		xOff, yOff := 0, 0

		switch direction {
		case 0:
			xOff = 1
		case 90:
			yOff = 1
		case 180:
			xOff = -1
		case 270:
			yOff = -1
		}

		for dist > 0 {
			x += xOff
			y += yOff

			dist--

			if visited[[2]int{x, y}] {
				return distance(x, y), nil
			}
			visited[[2]int{x, y}] = true
		}

	}

	return 0, errors.New("no location visited twice")
}

func main() {
	data, err := ioutil.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	input := strings.TrimSuffix(string(data), "\n")

	re := regexp.MustCompile(", *")
	tokens := re.Split(input, -1)

	distance, err := part1(tokens)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Part 1: %d\n", distance)

	distance, err = part2(tokens)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Part 2: %d\n", distance)
}
