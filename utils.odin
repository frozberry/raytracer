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

cmp_slice_f64 :: proc(a: []f64, b: []f64) -> bool {
	if len(a) != len(b) {
		return false
	}
	for i in 0..<len(a) {
		if !cmp_float(a[i], b[i]) {
			return false
		}
	}
	return true
}

cmp_sphere :: proc(a: Sphere, b: Sphere) -> bool {
	return a.id == b.id
}

cmp_intersection :: proc(a: Intersection, b: Intersection) -> bool {
	sphere := cmp_sphere(a.object, b.object)
	t := cmp_float(a.t, b.t)
	return sphere && t
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

PI :: math.PI

radians :: proc(n: f64) -> f64 {
	return (n * PI) / 180	
}

degrees :: proc(n: f64) -> f64 {
	return (n * 180) / PI
}

assert_matrix :: proc(a: Matrix, b: Matrix)  {
	if !(cmp_matrix(a, b)) {
		print_matrix(a)
		print_matrix(b)
	}
	assert(cmp_matrix(a, b))
	return
}

assert_tuple :: proc(a: Tuple, b: Tuple)  {
	if !cmp_tuple(a, b) {
		fmt.println(a)
		fmt.println(b)
	}
	assert(cmp_tuple(a, b))
	return
}

assert_f64 :: proc(a: f64, b: f64)  {
	fmt.println(a)
	fmt.println(b)
	assert(cmp_float(a, b))
	return
}

