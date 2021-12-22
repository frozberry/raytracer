package main

import "core:fmt"
import "core:os"

draw_sphere :: proc() {
	ray_origin := new_point(0, 0, -5)
	wall_z := 10.0
	wall_size := 7.0
	canvas_pixels := 100
	pixel_size := wall_size / f64(canvas_pixels)
	half := wall_size / 2
	canvas := new_canvas(canvas_pixels, canvas_pixels)
	color := new_color(1, 0, 0)
	shape := new_sphere()

	for y in 0 ..< canvas_pixels {
		// Flip y-axis
		world_y := half - pixel_size * f64(y)

		for x in 0 ..< canvas_pixels {
			world_x := -half + pixel_size * f64(x)

			destination := new_point(world_x, world_y, wall_z)

			ray_direction := normalize_tuple(sub_tuple(destination, ray_origin))
			r := new_ray(ray_origin, ray_direction)
			xs, hit := intersect(shape, r)

			if hit {
				write_pixel(&canvas, x, y, color)
			}
		}
	}
	ppm := canvas_to_ppm(canvas)
	os.write_entire_file("../sphere.ppm", ppm)
}
