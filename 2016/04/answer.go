package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

type room struct {
	name     string
	sector   int
	checksum string
}

func (r room) mostCommonLetters(count int) []rune {
	chars := make(map[rune]int)

	nameChars := strings.ReplaceAll(r.name, "-", "")
	for _, c := range nameChars {
		chars[c]++
	}

	type charWithCount struct {
		char  rune
		count int
	}

	counts := []charWithCount{}

	for char, count := range chars {
		counts = append(counts, charWithCount{char, count})
	}

	sort.Slice(counts, func(i, j int) bool {
		if counts[i].count > counts[j].count {
			return true
		} else if counts[i].count < counts[j].count {
			return false
		} else {
			return counts[i].char < counts[j].char
		}
	})

	letters := []rune{}

	for i, letter := range counts {
		if i >= 5 {
			break
		}

		letters = append(letters, letter.char)
	}

	return letters
}

func (r room) isReal() bool {
	return string(r.mostCommonLetters(5)) == r.checksum
}

func (r room) shiftName() string {
	shift := r.sector
	bytes := []byte(r.name)

	shiftedBytes := make([]byte, len(bytes))

	shift %= 26

	for i, b := range bytes {
		if 'a' <= b && b <= 'z' {
			b += byte(shift)
			if b > 'z' {
				b -= 26
			}
		}

		shiftedBytes[i] = b
	}

	return string(shiftedBytes)
}

func part1(rooms []room) int {
	sum := 0

	for _, r := range rooms {
		if r.isReal() {
			sum += r.sector
		}
	}

	return sum
}

func part2(rooms []room) int {
	re := regexp.MustCompile("northpole")
	for _, r := range rooms {
		if r.isReal() {
			decodedName := r.shiftName()
			if re.MatchString(decodedName) {
				return r.sector
			}
		}
	}
	return -1
}

func main() {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	rooms := make([]room, 0)
	scanner := bufio.NewScanner(file)
	re := regexp.MustCompile(`([-a-z]+)-([0-9]+)\[([a-z]{5})\]`)

	for scanner.Scan() {
		match := re.FindStringSubmatch(scanner.Text())

		roomName := match[1]
		sectorID, err := strconv.Atoi(match[2])
		if err != nil {
			log.Fatal(err)
		}
		checksum := match[3]

		rooms = append(rooms, room{roomName, sectorID, checksum})
	}

	fmt.Printf("Part 1: %d\n", part1(rooms))
	fmt.Printf("Part 2: %d\n", part2(rooms))
}
