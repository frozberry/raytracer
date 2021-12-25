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

sqrt :: proc(a: f64) -> f64 {
	return math.pow(a, 0.5)
}

sqr :: proc(a: f64) -> f64 {
	return math.pow(a, 2.0)
}

append_string_to_array :: proc(arr: ^[]u8, add: string, index: ^int) {
	for char_rune in add {
		b := cast(u8)char_rune
		arr[index^] = b
		index^ += 1
	}
}

int_to_string :: proc(n: int) -> string {
	return fmt.tprintf("%v", n)
}

clamp_255 :: proc(n: int) -> int {
	if n > 255 {
		return 255
	} else if n < 0 {
		return 0
	} else {
		return n
	}
}

PI :: math.PI
root2 := math.pow(f64(2), 0.5)
root3 := math.pow(f64(3), 0.5)


radians :: proc(n: f64) -> f64 {
	return (n * PI) / 180
}

degrees :: proc(n: f64) -> f64 {
	return (n * 180) / PI
}

assert_matrix :: proc(a: Matrix, b: Matrix) {
	if !(cmp_matrix(a, b)) {
		print_matrix(a)
		print_matrix(b)
	}
	assert(cmp_matrix(a, b))
	return
}

assert_tuple :: proc(a: Tuple, b: Tuple) {
	if !cmp_tuple(a, b) {
		fmt.println(a)
		fmt.println(b)
	}
	assert(cmp_tuple(a, b))
	return
}

assert_f64 :: proc(a: f64, b: f64) {
	fmt.println(a)
	fmt.println(b)
	assert(cmp_float(a, b))
	return
}
