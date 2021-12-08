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

	draw_clock()
}
