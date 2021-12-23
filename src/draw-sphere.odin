package main

import "core:fmt"
import "core:os"
import "core:time"

draw_sphere :: proc() {
	ray_origin := new_point(0, 0, -5)
	wall_z := 10.0
	wall_size := 7.0
	canvas_pixels := 300
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

draw_sphere_3d :: proc() {
	start := time.now()

	ray_origin := new_point(0, 0, -5)
	wall_z := 10.0
	wall_size := 7.0
	canvas_pixels := 500

	pixel_size := wall_size / f64(canvas_pixels)
	half := wall_size / 2

	canvas := new_canvas(canvas_pixels, canvas_pixels)

	// Fixed now with context.allocator instead of temp_allocator
	shape := new_sphere()
	shape.material = new_material()
	shape.material.color = new_color(0.2, 0.5, 1)
	shape.material.shininess = 200
	shape.material.ambient = 0.1
	shape.material.diffuse = 0.9
	shape.material.specular = 0.9

	t := new_scaling(1.0, 0.5, 0.5)
	set_transform(&shape, t)

	light_position := new_point(-10, 10, -10)
	light_color := new_color(1, 1, 1)
	light := new_point_light(light_position, light_color)


	for y in 0 ..< canvas_pixels {
		world_y := half - pixel_size * f64(y)

		for x in 0 ..< canvas_pixels {
			world_x := -half + pixel_size * f64(x)

			destination := new_point(world_x, world_y, wall_z)

			ray_direction := normalize_tuple(sub_tuple(destination, ray_origin))
			ray := new_ray(ray_origin, ray_direction)

			xs, hit := intersect(shape, ray)

			if hit {
				first_xs, _ := first_hit(xs[:])
				point := ray_position(ray, first_xs.t)
				normal := normal_at(first_xs.object, point)
				eye := negate_tuple(ray.direction)

				color := lighting(first_xs.object.material, light, point, eye, normal)

				write_pixel(&canvas, x, y, color)
			}
		}
	}

	end := time.now()
	fmt.println(time.diff(start, end))

	ppm := canvas_to_ppm(canvas)
	os.write_entire_file("../sphere3d.ppm", ppm)
}
