package main

import "core:math/rand"
import "core:fmt"

Sphere :: struct {
	id: u64,
	transform: Matrix,
}

new_sphere :: proc() -> Sphere {
	return Sphere{rand.uint64(), new_identity_matrix()}
}

set_transform :: proc(sphere: ^Sphere, transform: Matrix) {
	sphere.transform = transform
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

sphere_tests :: proc() {
	test_sphere_transformation()
	test_change_sphere_transformation()
	test_intersect_scaled_sphere_with_ray()
	test_intersect_translated_sphere_with_ray()
	
	
}

test_sphere_transformation :: proc() {
	s := new_sphere()
	assert(cmp_matrix(s.transform, new_identity_matrix()))
}

test_change_sphere_transformation :: proc() {
	s := new_sphere()
	t := new_translation(2, 3, 4)
	set_transform(&s, t)
	assert(cmp_matrix(s.transform, t))
}

test_intersect_scaled_sphere_with_ray :: proc() {
	r := new_ray(new_point(0, 0, -5), new_vector(0, 0, 1))
	s := new_sphere()
	set_transform(&s, new_scaling(2, 2, 2))
	xs, hit := intersect(s, r)
	assert(hit)
	assert(len(xs) == 2)
	assert(cmp_float(xs[0].t, 3))
	assert(cmp_float(xs[1].t, 7))
}

test_intersect_translated_sphere_with_ray :: proc() {
	r := new_ray(new_point(0, 0, -5), new_vector(0, 0, 1))
	s := new_sphere()
	set_transform(&s, new_translation(5, 0, 0))
	xs, hit := intersect(s, r)
	assert(!hit)
}
