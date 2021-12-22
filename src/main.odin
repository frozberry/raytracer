package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"


main :: proc() {
	tuple_tests()
	color_tests()
	canvas_tests()
	matrix_tests()
	transformation_tests()
	ray_tests()
	intersection_tests()
	sphere_tests()
	lights_tests()
	material_tests()

	draw_sphere_3d()

}
