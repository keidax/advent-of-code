package main

import (
	"bufio"
	"crypto/md5"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"golang.org/x/sys/unix"

	"github.com/fatih/color"
)

type digit struct {
	part  int
	digit int
	value byte
}

func hackThePlanet(doorID []byte, digits chan digit) {
	nonce := "00000"

	count1 := 0
	count2 := 0

	part2Found := make([]bool, 8)

	var i int64
	for i = 0; count2 < 8; i++ {
		input := strconv.AppendInt(doorID, i, 10)
		sum := md5.Sum(input)

		if sum[0] != 0 || sum[1] != 0 {
			// Skip string formatting
			continue
		}

		hex := fmt.Sprintf("%x", sum[0:4])
		if hex[0:5] == nonce {
			if count1 < 8 {
				count1++
				digits <- digit{part: 1, digit: count1, value: hex[5]}
			}

			part2Digit := sum[2] & 0xf
			if part2Digit > 7 {
				continue
			}

			if part2Found[part2Digit] {
				continue
			}
			part2Found[part2Digit] = true

			count2++
			digits <- digit{part: 2, digit: int(part2Digit + 1), value: hex[6]}
		}
	}

	close(digits)
}

func currentTermios(fd int) (unix.Termios, error) {
	var current *unix.Termios
	current, err := unix.IoctlGetTermios(fd, unix.TCGETS)
	if err != nil {
		return unix.Termios{}, err
	}

	return *current, nil
}

func applyTermios(fd int, value unix.Termios) error {
	err := unix.IoctlSetTermios(fd, unix.TCSETS, &value)
	return err
}

func getCursorPosition() (x, y int, err error) {
	originalSetting, err := currentTermios(0)
	if err != nil {
		return -1, -1, err
	}
	defer applyTermios(0, originalSetting)

	noEcho := originalSetting
	noEcho.Lflag &^= unix.ECHO | unix.ICANON

	if err := applyTermios(0, noEcho); err != nil {
		return -1, -1, err
	}

	fmt.Print("\033[6n")
	reader := bufio.NewReader(os.Stdin)

	_, err = reader.ReadString('[')
	if err != nil {
		return -1, -1, err
	}

	resp, err := reader.ReadString('R')
	if err != nil {
		return -1, -1, err
	}

	resp = resp[:len(resp)-1]

	pieces := strings.Split(resp, ";")
	row, err := strconv.Atoi(pieces[0])
	if err != nil {
		return -1, -1, err
	}
	col, err := strconv.Atoi(pieces[1])
	if err != nil {
		return -1, -1, err
	}
	return col, row, nil
}

func setCursorPosition(x, y int) {
	fmt.Printf("\033[%d;%dH", y, x)
}

func hideCursor() {
	fmt.Printf("\033[?25l")
}

func showCursor() {
	fmt.Printf("\033[?25h")
}

func main() {
	// input := []byte("abc")
	input := []byte("abbhdwsy")

	bold := color.New(color.Bold)
	red := color.New(color.FgRed)
	green := color.New(color.FgGreen, color.Bold)

	bold.Print("Part 1: ")
	red.Println("********")
	bold.Print("Part 2: ")
	red.Println("********")

	hideCursor()
	defer showCursor()

	x, y, err := getCursorPosition()
	if err != nil {
		log.Fatal(err)
	}

	startY := y - 3
	startX := 8

	digits := make(chan digit, 2)
	go hackThePlanet(input, digits)
	for digit := range digits {
		setCursorPosition(startX+digit.digit, startY+digit.part)
		green.Printf("%c", digit.value)
		setCursorPosition(x, y)
	}
}
