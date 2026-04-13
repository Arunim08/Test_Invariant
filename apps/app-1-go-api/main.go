package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from App-1 (Go API Server)! 🚀\n")
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status":"healthy","app":"app-1"}`)
	})

	http.HandleFunc("/info", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"app":"app-1","type":"Go API","hostname":"%s"}`, hostname)
	})

	port := ":8080"
	log.Printf("App-1 starting on %s\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
