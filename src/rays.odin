package main
import "core:math"
import "core:fmt"

Ray :: struct {
	origin:    Tuple,
	direction: Tuple,
}

new_ray :: proc(origin: Tuple, direction: Tuple) -> Ray {
	return Ray{origin, direction}
}

ray_position :: proc(ray: Ray, t: f64) -> Tuple {
	distance := mult_tuple(ray.direction, t)
	new_position := add_tuple(ray.origin, distance)
	return new_position
}

// Returns the t values where of an intersection
intersect :: proc(sphere: Sphere, r: Ray) -> ([2]Intersection, bool) {
	intersections: [2]Intersection 

	// Apply the sphere's transform to the ray
	ray_transform, _ := inverse_matrix(sphere.transform)
	ray := transform_ray(r, ray_transform)

	sphere_to_ray := sub_tuple(ray.origin, new_point(0, 0, 0))

	a := dot(ray.direction, ray.direction)
	b := 2.0 * dot(ray.direction, sphere_to_ray)
	c := dot(sphere_to_ray, sphere_to_ray) - 1

	discriminant := math.pow(b, 2) - (4 * a * c)

	if discriminant < 0 {
		return intersections, false
	}

	t1 := (-b - math.pow(discriminant, 0.5)) / (2 * a)
	t2 := (-b + math.pow(discriminant, 0.5)) / (2 * a)

	intersections[0] = new_intersection(t1, sphere)
	intersections[1] = new_intersection(t2, sphere)

	return intersections, true
}

transform_ray :: proc(ray: Ray, transform: Matrix) -> Ray {
	origin := mult_matrix_by_tuple(transform, ray.origin)
	direction := mult_matrix_by_tuple(transform, ray.direction)
	return new_ray(origin, direction)
}

ray_tests :: proc() {
	test_new_ray()
	test_point_from_distance()
	test_ray_sphere_intersect()
	test_intersect_tangent()
	test_miss_sphere()
	test_inside_sphere()
	test_sphere_is_behind_ray()
	test_translate_ray()
	test_scale_ray()
}

test_new_ray :: proc() {
	o := new_point(1, 2, 3)
	d := new_vector(4, 5, 6)
	r := new_ray(o, d)

	assert(cmp_tuple(r.origin, o))
	assert(cmp_tuple(r.direction, d))
}

test_point_from_distance :: proc() {
	r := new_ray(new_point(2, 3, 4), new_vector(1, 0, 0))

	assert(cmp_tuple(ray_position(r, 0), new_point(2, 3, 4)))
	assert(cmp_tuple(ray_position(r, 1), new_point(3, 3, 4)))
	assert(cmp_tuple(ray_position(r, -1), new_point(1, 3, 4)))
	assert(cmp_tuple(ray_position(r, 2.5), new_point(4.5, 3, 4)))
}

test_ray_sphere_intersect :: proc() {
	r := new_ray(new_point(0, 0, -5), new_vector(0, 0, 1))
	s := new_sphere()
	xs, hit := intersect(s, r)

	assert(hit)

	assert(cmp_float(xs[0].t, 4.0))
	assert(cmp_float(xs[1].t, 6.0))
}

test_intersect_tangent :: proc() {
	r := new_ray(new_point(0, 1, -5), new_vector(0, 0, 1))
	s := new_sphere()
	xs, hit := intersect(s, r)

	assert(hit)
	assert(cmp_float(xs[0].t, 5.0))
	assert(cmp_float(xs[1].t, 5.0))
}

test_miss_sphere :: proc() {
	r := new_ray(new_point(0, 2, -5), new_vector(0, 0, 1))
	s := new_sphere()
	xs, hit := intersect(s, r)

	assert(!hit)
	assert(cmp_float(xs[0].t, 0))
	assert(cmp_float(xs[0].t, 0))
}


test_inside_sphere :: proc() {
	r := new_ray(new_point(0, 0, 0), new_vector(0, 0, 1))
	s := new_sphere()
	xs, hit := intersect(s, r)

	assert(hit)
	assert(cmp_float(xs[0].t, -1.0))
	assert(cmp_float(xs[1].t, 1.0))
}


test_sphere_is_behind_ray :: proc() {
	r := new_ray(new_point(0, 0, 5), new_vector(0, 0, 1))
	s := new_sphere()
	xs, hit := intersect(s, r)

	assert(hit)
	assert(cmp_float(xs[0].t, -6.0))
	assert(cmp_float(xs[1].t, -4.0))
}

test_translate_ray :: proc() {
	r := new_ray(new_point(1, 2, 3), new_vector(0, 1, 0))
	m := new_translation(3, 4, 5)
	r2 := transform_ray(r, m)
	assert(cmp_tuple(r2.origin, new_point(4, 6, 8)))
	assert(cmp_tuple(r2.direction, new_vector(0, 1, 0)))
}

test_scale_ray :: proc() {
	r := new_ray(new_point(1, 2, 3), new_vector(0, 1, 0))
	m := new_scaling(2, 3, 4)
	r2 := transform_ray(r, m)

	assert(cmp_tuple(r2.origin, new_point(2, 6, 12)))
	assert(cmp_tuple(r2.direction, new_vector(0, 3, 0)))
}
