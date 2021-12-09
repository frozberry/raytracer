package main

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