package main
import "core:fmt"
import "core:math/bits"

Intersection :: struct {
	t:      f64,
	object: Sphere,
}

new_intersection :: proc(t: f64, object: Sphere) -> Intersection {
	return Intersection{t, object}
}

intersections :: proc(intersections: .. Intersection) -> []Intersection {
	return intersections
}

first_hit :: proc(intersections: []Intersection) -> (Intersection, bool) {
	assert(len(intersections) > 0, "Empty slice passed into first_hit()")
	// Creates a new intersection with max t for the compare to work
	// Maybe a better way to do this?
	i := new_intersection(f64(bits.U32_MAX), new_sphere())
	hit := false

	for inter in intersections {
		if inter.t >= 0.0 && inter.t <= i.t {
			i = inter
			hit = true
		}
	}
	return i, hit
}


/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */


intersection_tests :: proc() {
	test_new_intersection()
	test_aggregating_intersection()
	test_intersect_sets_the_object_on_intersection()
	test_hit()
	test_hit_negative_t()
	test_hit_all_negative_t()
	test_hit_lowest_non_negative()
}

test_new_intersection :: proc() {
	s := new_sphere()
	t := 3.5
	i := new_intersection(t, s)
	assert(i.t == 3.5)
}

test_aggregating_intersection :: proc() {
	s := new_sphere()
	i1 := new_intersection(1, s)
	i2 := new_intersection(2, s)
	xs := intersections(i1, i2)
	assert(len(xs) == 2)
	assert(cmp_float(xs[0].t, 1))
	assert(cmp_float(xs[1].t, 2))
}

test_intersect_sets_the_object_on_intersection :: proc() {
	r := new_ray(new_point(0, 0, -5), new_vector(0, 0, 1))
	s := new_sphere()
	xs, _ := intersect(s, r)
	assert(len(xs) == 2)
	assert(cmp_sphere(xs[0].object, s))
	assert(cmp_sphere(xs[1].object, s))
}

test_hit :: proc() {
	s := new_sphere()
	i1 := new_intersection(1, s)
	i2 := new_intersection(2, s)
	xs := intersections(i2, i1)
	i, hit := first_hit(xs)
	assert(hit)
	assert(cmp_intersection(i, i1))
}

test_hit_negative_t :: proc() {
	s := new_sphere()
	i1 := new_intersection(-1, s)
	i2 := new_intersection(2, s)
	xs := intersections(i2, i1)
	i, hit := first_hit(xs)
	assert(hit)
	assert(cmp_intersection(i, i2))
}

test_hit_all_negative_t :: proc() {
	s := new_sphere()
	i1 := new_intersection(-2, s)
	i2 := new_intersection(-1, s)
	xs := intersections(i2, i1)
	i, hit := first_hit(xs)
	assert(!hit)
}

test_hit_lowest_non_negative :: proc() {
	s := new_sphere()
	i1 := new_intersection(5, s)
	i2 := new_intersection(7, s)
	i3 := new_intersection(-3, s)
	i4 := new_intersection(2, s)
	xs := intersections(i1, i2, i3, i4)
	i, hit := first_hit(xs)
	assert(hit)
	assert(cmp_intersection(i, i4))
}
