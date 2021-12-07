package main
import "core:fmt"

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