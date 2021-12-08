package main

import "core:fmt"
import "core:os"

draw_clock :: proc() {
	width := 500
	height := 500

	w_scaling := f64(width) * 0.4
	h_scaling := f64(height) * 0.4

	canvas := new_canvas(width, height)
	white := new_color(255, 255, 255)
	twelve := new_point(0, 0, 1)

	for i in 0..<12 {
		angle := f64(i) * (PI / 6)

		rotation := new_rotation_y(f64(i) * PI / 6)
		scaling := new_scaling(w_scaling, 0, h_scaling)
		transformation := combine_transformations(rotation, scaling)

		point: = mult_matrix_by_tuple(transformation, twelve)
		w, h := point_to_w_h(point)

		write_pixel(&canvas, w, h, white )
	}

	ppm := canvas_to_ppm(canvas)
	os.write_entire_file("clock.ppm", ppm)
	return
}

point_to_w_h :: proc(p: Tuple) -> (int, int) {
	return int(p.x + 250), int(250 - (p.z))
}