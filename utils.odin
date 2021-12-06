package main
import "core:math"

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
