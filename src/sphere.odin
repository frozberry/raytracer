package main

import "core:math/rand"
import "core:fmt"
import "core:math"

Sphere :: struct {
	id:        u64,
	transform: Matrix,
	material:  Material,
}

new_sphere :: proc() -> Sphere {
	return Sphere{rand.uint64(), new_identity_matrix(), new_material()}
}

set_transform :: proc(sphere: ^Sphere, transform: Matrix) {
	sphere.transform = transform
}

normal_at :: proc(sphere: Sphere, world_point: Tuple) -> Tuple {
	inverse_sphere, _ := inverse_matrix(sphere.transform)
	object_point := mult_matrix_by_tuple(inverse_sphere, world_point)
	object_normal := sub_tuple(object_point, new_point(0, 0, 0))
	world_normal := mult_matrix_by_tuple(transpose_matrix(inverse_sphere), object_normal)
	world_normal.w = 0
	return normalize_tuple(world_normal)
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

sphere_tests :: proc() {
	test_sphere_transformation()
	test_change_sphere_transformation()
	test_intersect_scaled_sphere_with_ray()
	test_intersect_translated_sphere_with_ray()
	test_normal_x()
	test_normal_y()
	test_normal_z()
	test_non_axial_normal()
	test_normal_on_translated_sphere()
	test_normal_on_transformed_sphere()
	test_sphere_material()
	test_sphere_assign_material()
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

test_normal_x :: proc() {
	s := new_sphere()
	n := normal_at(s, new_point(1, 0, 0))
	assert(cmp_tuple(n, new_vector(1, 0, 0)))
}

test_normal_y :: proc() {
	s := new_sphere()
	n := normal_at(s, new_point(0, 1, 0))
	assert(cmp_tuple(n, new_vector(0, 1, 0)))
}

test_normal_z :: proc() {
	s := new_sphere()
	n := normal_at(s, new_point(0, 0, 1))
	assert(cmp_tuple(n, new_vector(0, 0, 1)))
}

test_non_axial_normal :: proc() {
	s := new_sphere()
	trt := math.pow(f64(3.0), 0.5) / 3.0
	n := normal_at(s, new_point(trt, trt, trt))
	assert(cmp_tuple(n, normalize_tuple(n)))
}

test_normal_on_translated_sphere :: proc() {
	s := new_sphere()
	set_transform(&s, new_translation(0, 1, 0))

	n := normal_at(s, new_point(0, 1.70711, -0.70711))
	assert(cmp_tuple(n, new_vector(0, 0.70711, -0.70711)))
}

test_normal_on_transformed_sphere :: proc() {
	s := new_sphere()
	t := combine_transformations(new_scaling(1, 0.5, 1), new_rotation_z(PI / 5))
	set_transform(&s, t)

	trt := math.pow(f64(2), 2)
	n := normal_at(s, new_point(0, trt, -trt))
	assert(cmp_tuple(n, new_vector(0, 0.97014, -0.24254)))
}

test_sphere_material :: proc() {
	s := new_sphere()
	assert(cmp_material(s.material, new_material()))
}


test_sphere_assign_material :: proc() {
	s := new_sphere()
	m := new_material()
	m.ambient = 1
	s.material = m
	assert(cmp_material(s.material, m))
}
