package main

import "core:fmt"

main :: proc() {
	test :=
		"{" +
		"\"key1\": true," +
		"\"key2\": false," +
		"\"key3\": null," +
		"\"key4\": \"value\"," +
		"\"key5\": 101," +
		"\"key6\": {" +
		"\"key\": \"value\"," +
		"\"key-n\": 101," +
		"\"key-o\": {}," +
		"\"key-l\": []" +
		"}}"
	pretty_print(test)
}
