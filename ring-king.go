package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

var wg sync.WaitGroup

type Process struct {
	in  [2]chan int
	out [2]chan int
	id  int
}

func (process *Process) run() {
	for {
		go func() {
			process.out[0] <- process.id
			fmt.Printf("sent left (%d)\n", process.id)
		}()
		go func() {
			process.out[1] <- process.id
			fmt.Printf("sent right (%d)\n", process.id)
		}()

		l, r := <-process.in[0], <-process.in[1]
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
			tmp := <-process.in[1]
			process.out[0] <- tmp
		}
	}()
	go func() {
		for {
			tmp := <-process.in[0]
			process.out[1] <- tmp
		}
	}()
}

func main() {
	rand.Seed(time.Now().UTC().UnixNano())

	n := 1024
	processes := make([]Process, n)
	channels := make([]chan int, 2*n)
	for i := 0; i < 2*n; i++ {
		channels[i] = make(chan int)
	}

	perm := rand.Perm(n)
	for i := 0; i < n; i++ {
		processes[i].id = perm[i]
		processes[i].in[1] = channels[i]
		processes[i].in[0] = channels[n+(i-1+n)%n]
		processes[i].out[1] = channels[n+i]
		processes[i].out[0] = channels[(i-1+n)%n]
	}

	wg.Add(1)
	for i := 0; i < n; i++ {
		go processes[i].run()
	}
	wg.Wait() // for king election
}
