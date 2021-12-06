package main
import "core:math"
import "core:fmt"

abs :: proc(n: f64) -> f64 {
	if n < 0 {
		return -(n)
	} else {
		return n
	}
}

cmp_float :: proc(a: f64, b: f64) -> bool {
	EPSILON := 0.00001
	return abs(a - b) < EPSILON
}

cmp_slice :: proc(a: []u8, b: []u8) -> bool {
	if len(a) != len(b) {
		return false
	}
	for i in 0..<len(a) {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

sqrt :: proc(a: f64) -> f64 {
	return math.pow(a, 0.5)
}

sqr :: proc(a: f64) -> f64 {
	return math.pow(a, 2.0)
}

append_bytes :: proc(arr: ^[dynamic]u8, add: string) {
	for i in add {
		append(arr, cast(u8)i)
	}
}

int_to_string :: proc(n: int) -> string {
	return fmt.tprintf("%v", n) 
}

clamp_255 :: proc(n: int) -> int{
	if n > 255 {
		return 255 
	} else if n < 0 {
		return 0
	} else {
		return n
	}
}