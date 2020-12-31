package main

import (
	"crypto/md5"
	"fmt"
	"strconv"

	"github.com/keidax/advent-of-code/aoc"
)

func part1(doorID []byte) []byte {
	digits := []byte{}
	nonce := "00000"

	var i int64
	for i = 0; len(digits) < 8; i++ {
		input := strconv.AppendInt(doorID, i, 10)
		sum := md5.Sum(input)

		if sum[0] != 0 || sum[1] != 0 {
			// Skip string formatting
			continue
		}

		hex := fmt.Sprintf("%x", sum[0:3])
		if hex[0:5] == nonce {
			digits = append(digits, hex[5])
		}
	}

	return digits
}

func part2(doorID []byte) []byte {
	digits := make([]byte, 8)
	found := 0
	nonce := "00000"

	var i int64
	for i = 0; found < 8; i++ {
		input := strconv.AppendInt(doorID, i, 10)
		sum := md5.Sum(input)

		if sum[0] != 0 || sum[1] != 0 {
			// Skip string formatting
			continue
		}

		hex := fmt.Sprintf("%x", sum[0:4])
		if hex[0:5] == nonce {
			digit := sum[2] & 0xf

			if digit > 7 {
				continue
			}

			if digits[digit] > 0 {
				// Only use the first result for each position
				continue
			}

			digits[digit] = hex[6]
			found++
		}
	}

	return digits
}

func main() {
	// input := []byte("abc")
	input := []byte("abbhdwsy")

	aoc.Part1(part1(input))
	aoc.Part2(part2(input))
}
