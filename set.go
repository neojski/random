package main

import (
	"fmt"
	"strings"
)

type Set map[int]bool

func (set Set) Add(x ...int) {
	for _, v := range x {
		set[v] = true
	}
}

func (set Set) Remove(x ...int) {
	for _, v := range x {
		delete(set, v)
	}
}

func (set Set) Empty() bool {
	return len(set) == 0
}

func (set Set) Size() int {
	return len(set)
}

func (set Set) String() (res string) {
	all := make([]string, 0, len(set))
	for k := range set {
		all = append(all, fmt.Sprintf("%v", k))
	}
	return "{" + strings.Join(all, ", ") + "}"
}

func NewSet() Set {
	return Set{}
}

func main() {
	x := NewSet()
	x.Add(1)
	x.Add(4)
	x.Add(1, 3, 5)
	x.Remove(2, 4)

	fmt.Printf("%v, size == %v\n", x, x.Size())
	fmt.Printf("empty: %v\n", x.Empty())
}

