package main

Tuple :: struct {
	x: f64,
	y: f64,
	z: f64,
	w: f64,
}

new_tuple :: proc(x: f64, y: f64, z: f64, w: f64) -> Tuple {
	return Tuple {x, y, z, w}
}

new_point :: proc(x: f64, y: f64, z: f64) -> Tuple {
	return Tuple {x, y, z, 1.0}
}

new_vector :: proc(x: f64, y: f64, z: f64) -> Tuple {
	return Tuple {x, y, z, 0.0}
}

cmp_tuple :: proc(a: Tuple, b: Tuple) -> bool {
	x := cmp_float(a.x, b.x) 
	y := cmp_float(a.y, b.y) 
	z := cmp_float(a.z, b.z) 
	w := cmp_float(a.w, b.w) 
	return x && y && z && w
}

add_tuple :: proc(a: Tuple, b: Tuple) -> Tuple {
	t := Tuple{a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w}
	assert(!cmp_float(t.w, 2.0))
	return t
}

sub_tuple :: proc(a: Tuple, b: Tuple) -> Tuple {
	t := Tuple{a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w}
	assert(!(t.w <0.0))
	return t
}

negate_tuple :: proc(a: Tuple) -> Tuple {
	return Tuple{-a.x, -a.y, -a.z, -a.w}
}

mult_tuple :: proc(a: Tuple, b: f64) -> Tuple {
	return Tuple{a.x * b, a.y * b, a.z * b, a.w * b}
}

div_tuple :: proc(a: Tuple, b: f64) -> Tuple {
	return Tuple{a.x / b, a.y / b, a.z / b, a.w / b}
}

magnitude_tuple :: proc(a: Tuple) -> f64 {
	sum := sqr(a.x) + sqr(a.y) + sqr(a.z) + sqr(a.w) 
	return sqrt(sum)
}

normalize_tuple :: proc(a: Tuple) -> Tuple {
	mag := magnitude_tuple(a)
	return new_tuple(a.x / mag, a.y / mag, a.z / mag, a.w / mag)
}

dot :: proc(a: Tuple, b: Tuple) -> f64 {
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
}

cross :: proc(a: Tuple, b: Tuple) -> Tuple {
	return new_vector(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
}

// Tests
tuple_tests :: proc() {
	p := new_point(4.3, -4.2, 3.1)
	v := new_vector(4.3, -4.2, 3.1)

	assert(p.x == 4.3)
	assert(p.y == -4.2)
	assert(p.z == 3.1)
	assert(p.w == 1.0)

	assert(v.x == 4.3)
	assert(v.y == -4.2)
	assert(v.z == 3.1)
	assert(v.w == 0.0)

	assert(!cmp_tuple(p, v))

	// Add tuples
	a1 := Tuple{3, -2, 5, 1}
	a2 := Tuple{-2, 3, 1, 0}
	added := add_tuple(a1, a2)
	add_expected := Tuple{1, 1, 6, 1}
	assert(cmp_tuple(added, add_expected))

	// Sub tuples
	test_sub()
	test_sub2()
	test_sub3()

	test_sub_from_zero()
	test_negate()

	test_mult()
	test_mult2()

	test_div()
	test_magnitudes()

	test_norm()
	test_norm2()

	test_dot()
	test_cross()
	test_cross2()


	//
	return
}

test_sub :: proc() {
	a := new_point(3, 2, 1)	
	b := new_point(5, 6, 7)	
	actual := sub_tuple(a, b)
	expected := new_vector(-2, -4, -6) 
	assert(cmp_tuple(actual, expected))
}

test_sub2 :: proc() {
	a := new_point(3, 2, 1)	
	b := new_vector(5, 6, 7)	
	actual := sub_tuple(a, b)
	expected := new_point(-2, -4, -6) 
	assert(cmp_tuple(actual, expected))
}

test_sub3 :: proc() {
	a := new_vector(3, 2, 1)	
	b := new_vector(5, 6, 7)	
	actual := sub_tuple(a, b)
	expected := new_vector(-2, -4, -6) 
	assert(cmp_tuple(actual, expected))
}

test_sub_from_zero :: proc() {
	a := new_vector(0, 0, 0)	
	b := new_vector(1, -2, 3)	
	actual := sub_tuple(a, b)
	expected := new_vector(-1, 2, -3) 
	assert(cmp_tuple(actual, expected))
}

test_negate :: proc() {
	a := new_tuple(1, -2, 3, -4)	
	actual := negate_tuple(a)
	expected := new_tuple(-1, 2, -3, 4) 
	assert(cmp_tuple(actual, expected))
}

test_mult :: proc() {
	a := new_tuple(1, -2, 3, -4)	
	actual := mult_tuple(a, 3.5)
	expected := new_tuple(3.5, -7, 10.5, -14) 
	assert(cmp_tuple(actual, expected))
}

test_mult2 :: proc() {
	a := new_tuple(1, -2, 3, -4)	
	actual := mult_tuple(a, 0.5)
	expected := new_tuple(0.5, -1, 1.5, -2) 
	assert(cmp_tuple(actual, expected))
}


test_div :: proc() {
	a := new_tuple(1, -2, 3, -4)	
	actual := div_tuple(a, 2)
	expected := new_tuple(0.5, -1, 1.5, -2) 
	assert(cmp_tuple(actual, expected))
}

test_magnitudes :: proc() {
	a := new_vector(1, 0, 0)
	b := new_vector(0, 1, 0)
	c := new_vector(0, 0, 1)
	d := new_vector(1, 2, 3)
	e := new_vector(-1, -2, -3)

	ae := 1.0
	be := 1.0
	ce := 1.0
	de := sqrt(14)
	ee := sqrt(14)

	assert(cmp_float(magnitude_tuple(a), ae))
	assert(cmp_float(magnitude_tuple(b), be))
	assert(cmp_float(magnitude_tuple(c), ce))
	assert(cmp_float(magnitude_tuple(d), de))
	assert(cmp_float(magnitude_tuple(e), ee))
}

test_norm :: proc() {
	a := new_vector(4, 0, 0)	
	actual := normalize_tuple(a)
	expected := new_vector(1, 0, 0) 
	assert(cmp_tuple(actual, expected))
}

test_norm2 :: proc() {
	a := new_vector(1, 2, 3)	
	actual := normalize_tuple(a)
	expected := new_vector(1/sqrt(14), 2/sqrt(14), 3/sqrt(14)) 
	assert(cmp_tuple(actual, expected))
}

test_dot :: proc() {
	a := new_vector(1, 2, 3)	
	b := new_vector(2, 3, 4)	
	actual := dot(a, b)
	expected := 20.0
	assert(cmp_float(actual, expected))
}

test_cross :: proc() {
	a := new_vector(1, 2, 3)	
	b := new_vector(2, 3, 4)	
	actual := cross(a, b)
	expected := new_vector(-1, 2, -1) 
	assert(cmp_tuple(actual, expected))
}

test_cross2 :: proc() {
	a := new_vector(1, 2, 3)	
	b := new_vector(2, 3, 4)	
	actual := cross(b, a)
	expected := new_vector(1, -2, 1) 
	assert(cmp_tuple(actual, expected))
}