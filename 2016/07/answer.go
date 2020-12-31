package main

import (
	"bytes"

	"github.com/keidax/advent-of-code/aoc"
)

type ipV7Addr struct {
	supernetSequences [][]byte
	hypernetSequences [][]byte
}

func newAddr() ipV7Addr {
	return ipV7Addr{
		supernetSequences: make([][]byte, 0),
		hypernetSequences: make([][]byte, 0),
	}
}

func (addr *ipV7Addr) SupportsTLS() bool {
	for _, sequence := range addr.hypernetSequences {
		if hasAbba(sequence) {
			return false
		}
	}

	for _, sequence := range addr.supernetSequences {
		if hasAbba(sequence) {
			return true
		}
	}

	return false
}

func (addr *ipV7Addr) SupportsSSL() bool {
	abas := make([][]byte, 0)

	for _, sequence := range addr.supernetSequences {
		abas = append(abas, findAbas(sequence)...)
	}

	for _, aba := range abas {
		a, b := aba[0], aba[1]
		bab := []byte{b, a, b}

		for _, sequence := range addr.hypernetSequences {
			if bytes.Contains(sequence, bab) {
				return true
			}
		}
	}
	return false
}

func hasAbba(sequence []byte) bool {
	for i := 0; (i + 3) < len(sequence); i++ {
		char0 := sequence[i]
		char1 := sequence[i+1]

		if char0 == char1 {
			continue
		}

		if char0 == sequence[i+3] && char1 == sequence[i+2] {
			return true
		}
	}

	return false
}

func findAbas(sequence []byte) [][]byte {
	abas := make([][]byte, 0)

	for i := 0; (i + 2) < len(sequence); i++ {
		char0 := sequence[i]
		char1 := sequence[i+1]

		if char0 == char1 {
			continue
		}

		if char0 == sequence[i+2] {
			abas = append(abas, []byte{char0, char1, char0})
		}
	}

	return abas
}

func part1(addrs []ipV7Addr) int {
	count := 0
	for _, addr := range addrs {
		if addr.SupportsTLS() {
			count++
		}
	}

	return count
}

func part2(addrs []ipV7Addr) int {
	count := 0
	for _, addr := range addrs {
		if addr.SupportsSSL() {
			count++
		}
	}

	return count
}

func main() {
	lines, err := aoc.InputBytes()
	if err != nil {
		panic(err)
	}

	addrs := make([]ipV7Addr, 0)

	for _, line := range lines {
		newAddr := newAddr()
		pieces := bytes.Split(line, []byte("["))

		// The first piece can be appended directly
		newAddr.supernetSequences = append(newAddr.supernetSequences, pieces[0])
		pieces = pieces[1:]

		for _, piece := range pieces {
			sequences := bytes.Split(piece, []byte("]"))
			newAddr.hypernetSequences = append(newAddr.hypernetSequences, sequences[0])
			newAddr.supernetSequences = append(newAddr.supernetSequences, sequences[1])
		}

		addrs = append(addrs, newAddr)
	}

	aoc.Part1(part1(addrs))
	aoc.Part2(part2(addrs))
}
