package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from App-2 (Go Worker)! 📦\n")
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status":"healthy","app":"app-2","uptime":"%d"}`, time.Now().Unix())
	})

	http.HandleFunc("/metrics", func(w http.ResponseWriter, r *http.Request) {
		hostname, _ := os.Hostname()
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"app":"app-2","type":"Go Worker","hostname":"%s","timestamp":"%s"}`, hostname, time.Now().String())
	})

	port := ":8080"
	log.Printf("App-2 starting on %s\n", port)
	log.Fatal(http.ListenAndServe(port, nil))
}
