package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	ch := make(chan string)
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(i int) {
			ch <- fmt.Sprintf("%d", i)
		}(i)
	}

	go func() {
		for ip := range ch {
			fmt.Println(ip)
			wg.Done()
		}
	}()

	wg.Wait()
}
