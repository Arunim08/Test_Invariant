package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
)

var (
	cache = make(map[string]string)
	mu    = sync.RWMutex{}
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from App-3 (Go Cache Server)! 🗃️\n")
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status":"healthy","app":"app-3"}`)
	})

	http.HandleFunc("/cache/size", func(w http.ResponseWriter, r *http.Request) {
		mu.RLock()
		size := len(cache)
		mu.RUnlock()
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"app":"app-3","cache_size":%d}`, size)
	})

	http.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"app":"app-3","type":"Go Cache","hostname":"%s"}`, hostname)
	})

	port := ":8080"
	log.Printf("App-3 starting on %s\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
