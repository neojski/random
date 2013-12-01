package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var wg sync.WaitGroup

type Process struct {
	in  chan int
	out chan int
	id  int
}

func (process *Process) run() {
	for {
		go func() {
			process.out <- process.id
			fmt.Printf("sent right (%d)\n", process.id)
		}()

		l1 := <-process.in
		go func() {
			process.out <- l1
			fmt.Printf("sent right 2 (%d)\n", process.id)
		}()
		l2 := <-process.in

		// rename: I behave like my left neighbour
		l := l2
		r := process.id
		process.id = l1
		if l == process.id || r == process.id { // I'm talking to myself
			fmt.Printf("I'm the king (%d)!", process.id)
			wg.Done()
			return
		}
		if process.id < l || process.id < r {
			fmt.Printf("die! (%d)\n", process.id)
			break
		} else {
			fmt.Printf("live! (%d)\n", process.id)
		}
	}

	// after dying just forward messages
	go func() {
		for {
			tmp := <-process.in
			process.out <- tmp
		}
	}()
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	n := 1024
	processes := make([]Process, n)
	channels := make([]chan int, n)
	for i := 0; i < n; i++ {
		channels[i] = make(chan int)
	}

	perm := rand.Perm(n)
	for i := 0; i < n; i++ {
		processes[i].id = perm[i]
		processes[i].in = channels[(i-1+n)%n]
		processes[i].out = channels[i%n]
	}

	wg.Add(1)
	for i := 0; i < n; i++ {
		go processes[i].run()
	}
	wg.Wait() // for king election
}
