package main
import "core:fmt"
import "core:math"


new_translation :: proc(x: f64, y: f64, z: f64) -> Matrix {
	i := new_identity_matrix()
	write_matrix(&i, 0, 3, x)
	write_matrix(&i, 1, 3, y)
	write_matrix(&i, 2, 3, z)

	return i
}

new_scaling :: proc(x: f64, y: f64, z: f64) -> Matrix {
	i := new_identity_matrix()
	write_matrix(&i, 0, 0, x)
	write_matrix(&i, 1, 1, y)
	write_matrix(&i, 2, 2, z)
	return i
}

new_rotation_x :: proc(r: f64) -> Matrix {
	i := new_identity_matrix()

	write_matrix(&i, 1, 1, math.cos(r))
	write_matrix(&i, 1, 2, -math.sin(r))
	write_matrix(&i, 2, 1, math.sin(r))
	write_matrix(&i, 2, 2, math.cos(r))
	return i
}

new_rotation_y :: proc(r: f64) -> Matrix {
	i := new_identity_matrix()

	write_matrix(&i, 0, 0, math.cos(r))
	write_matrix(&i, 0, 2, math.sin(r))
	write_matrix(&i, 2, 0, -math.sin(r))
	write_matrix(&i, 2, 2, math.cos(r))
	return i
}

new_rotation_z :: proc(r: f64) -> Matrix {
	i := new_identity_matrix()

	write_matrix(&i, 0, 0, math.cos(r))
	write_matrix(&i, 0, 1, -math.sin(r))
	write_matrix(&i, 1, 0, math.sin(r))
	write_matrix(&i, 1, 1, math.cos(r))
	return i
}

new_shearing :: proc(xy: f64, xz: f64, yx: f64, yz: f64, zx: f64, zy: f64) -> Matrix {
	i := new_identity_matrix()

	write_matrix(&i, 0, 1, xy)
	write_matrix(&i, 0, 2, xz)
	write_matrix(&i, 1, 0, yx)
	write_matrix(&i, 1, 2, yz)
	write_matrix(&i, 2, 0, zx)
	write_matrix(&i, 2, 1, zy)

	return i
}

combine_transformations :: proc(m: ..Matrix) -> Matrix{
	assert(len(m) >= 2, "Must combine at least 2 transformations")
	combined := mult_matrix(m[0], m[1]) 

	for i in 2..<len(m) {
		combined = mult_matrix(m[i], combined)
	}
	return combined
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */
transformation_tests :: proc() {
	test_multiply_by_translation_matrix()
	test_multiply_by_translation_matrix_inv()
	test_vectors_not_translated()
	test_scaling_point()
	test_scaling_vector()
	test_scaling_inverse()
	test_reflection()
	test_rotation_x()
	test_inverse_rotation_x()
	test_rotation_y()
	test_rotation_z()
	test_shearing_1()
	test_shearing_2()
	test_shearing_3()
	test_shearing_4()
	test_shearing_5()
	test_shearing_6()
	test_transformations_in_sequence()
	test_transformations_in_reverse_order()
}

test_multiply_by_translation_matrix :: proc() {
	t := new_translation(5, -3, 2)
	p := new_point(-3, 4, 5)

	a := mult_matrix_by_tuple(t, p)
	e := new_point(2, 1, 7)
	
	assert(cmp_tuple(a, e))
}

test_multiply_by_translation_matrix_inv :: proc() {
	t := new_translation(5, -3, 2)
	inv, _ := inverse_matrix(t)
	p := new_point(-3, 4, 5)

	a := mult_matrix_by_tuple(inv, p)
	e := new_point(-8, 7, 3)
	assert(cmp_tuple(a, e))
}

test_vectors_not_translated :: proc() {
	t := new_translation(5, -3, 2)
	v := new_vector(-3, 4, 5)

	a := mult_matrix_by_tuple(t, v)
	assert(cmp_tuple(a, v))
}

test_scaling_point :: proc() {
	t := new_scaling(2, 3, 4)
	p := new_point(-4, 6, 8)

	a := mult_matrix_by_tuple(t, p)
	e := new_point(-8, 18, 32)

	assert(cmp_tuple(a, e))
}

test_scaling_vector :: proc() {
	t := new_scaling(2, 3, 4)
	v := new_vector(-4, 6, 8)

	a := mult_matrix_by_tuple(t, v)
	e := new_vector(-8, 18, 32)
	assert(cmp_tuple(a, e))
}

test_scaling_inverse :: proc() {
	t := new_scaling(2, 3, 4)
	inv, _ := inverse_matrix(t)
	v := new_vector(-4, 6, 8)

	a := mult_matrix_by_tuple(inv, v)
	e := new_vector(-2, 2, 2)
	assert(cmp_tuple(a, e))
}

test_reflection :: proc() {
	t := new_scaling(-1, 1, 1)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(t, p)
	e := new_point(-2, 3, 4)
	assert(cmp_tuple(a, e))
}

test_rotation_x :: proc() {
	p := new_point(0, 1, 0)
	hq := new_rotation_x(PI / 4)
	fq := new_rotation_x(PI / 2)

	e1 := new_point(0, math.pow(f64(2), 0.5)/ 2, math.pow(f64(2), 0.5)/ 2)
	e2 := new_point(0, 0, 1)

	a1 := mult_matrix_by_tuple(hq, p)
	a2 := mult_matrix_by_tuple(fq, p)

	assert_tuple(a1, e1)
	assert_tuple(a2, e2)
}


test_inverse_rotation_x :: proc() {
	p := new_point(0, 1, 0)
	hq := new_rotation_x(PI / 4)
	inv, _ := inverse_matrix(hq)

	e := new_point(0, math.pow(f64(2), 0.5)/ 2, -math.pow(f64(2), 0.5)/ 2)
	a := mult_matrix_by_tuple(inv, p)
	assert_tuple(a, e)
}

test_rotation_y :: proc() {
	p := new_point(0, 0, 1)
	hq := new_rotation_y(PI / 4)
	fq := new_rotation_y(PI / 2)

	e1 := new_point(math.pow(f64(2), 0.5)/ 2, 0, math.pow(f64(2), 0.5)/ 2)
	e2 := new_point(1, 0, 0)

	a1 := mult_matrix_by_tuple(hq, p)
	a2 := mult_matrix_by_tuple(fq, p)

	assert_tuple(a1, e1)
	assert_tuple(a2, e2)
}

test_rotation_z :: proc() {
	p := new_point(0, 1, 0)
	hq := new_rotation_z(PI / 4)
	fq := new_rotation_z(PI / 2)

	e1 := new_point(-math.pow(f64(2), 0.5)/ 2, math.pow(f64(2), 0.5)/ 2, 0)
	e2 := new_point(-1, 0, 0)

	a1 := mult_matrix_by_tuple(hq, p)
	a2 := mult_matrix_by_tuple(fq, p)

	assert_tuple(a1, e1)
	assert_tuple(a2, e2)
}

test_shearing_1 :: proc() {
	s := new_shearing(1, 0, 0, 0, 0, 0)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(5, 3, 4)

	assert_tuple(a, e)
}

test_shearing_2 :: proc() {
	s := new_shearing(0, 1, 0, 0, 0, 0)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(6, 3, 4)

	assert_tuple(a, e)
}

test_shearing_3 :: proc() {
	s := new_shearing(0, 0, 1, 0, 0, 0)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(2, 5, 4)

	assert_tuple(a, e)
}

test_shearing_4 :: proc() {
	s := new_shearing(0, 0, 0, 1, 0, 0)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(2, 7, 4)

	assert_tuple(a, e)
}

test_shearing_5 :: proc() {
	s := new_shearing(0, 0, 0, 0, 1, 0)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(2, 3, 6)

	assert_tuple(a, e)
}

test_shearing_6 :: proc() {
	s := new_shearing(0, 0, 0, 0, 0, 1)
	p := new_point(2, 3, 4)

	a := mult_matrix_by_tuple(s, p)
	e := new_point(2, 3, 7)

	assert_tuple(a, e)
}

test_transformations_in_sequence :: proc() {
	p := new_point(1, 0, 1)
	a := new_rotation_x(PI / 2)
	b := new_scaling(5, 5, 5)
	c := new_translation(10, 5, 7)

	p2 := mult_matrix_by_tuple(a, p)
	e2 := new_point(1, -1, 0)

	p3 := mult_matrix_by_tuple(b, p2)
	e3 := new_point(5, -5, 0)

	p4 := mult_matrix_by_tuple(c, p3)
	e4 := new_point(15, 0, 7)

	assert_tuple(p2, e2)
	assert_tuple(p3, e3)
	assert_tuple(p4, e4)
}

test_transformations_in_reverse_order :: proc() {
	p := new_point(1, 0, 1)
	a := new_rotation_x(PI / 2)
	b := new_scaling(5, 5, 5)
	c := new_translation(10, 5, 7)

	t := combine_transformations(a, b, c)
	actual := mult_matrix_by_tuple(t, p)
	
	e := new_point(15, 0, 7)
	assert_tuple(actual, e)
}