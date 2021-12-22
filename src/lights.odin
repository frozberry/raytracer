package main

import "core:fmt"

PointLight :: struct {
	position:  Tuple,
	intensity: Color,
}

new_point_light :: proc(position: Tuple, intensity: Color) -> PointLight {
	return PointLight{position, intensity}
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

lights_tests :: proc() {
	test_new_light()
}

test_new_light :: proc() {
	i := new_color(1, 1, 1)
	p := new_point(0, 0, 0)
	l := new_point_light(p, i)
	assert(cmp_color(i, l.intensity))
	assert(cmp_tuple(p, l.position))
}
