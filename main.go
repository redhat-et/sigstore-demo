package main

import (
	"io"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, req *http.Request) {
	io.WriteString(w, "Hello Dry Run World on Monday morning!\n")
}

func main() {
	// Hello world, the web server
	http.HandleFunc("/", helloHandler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}
