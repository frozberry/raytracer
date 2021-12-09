package main
import "core:os"

Projectile :: struct {
	position: Tuple,
	velocity: Tuple,
}

Environment :: struct {
	gravity: Tuple,
	wind:    Tuple,
}

tick :: proc(env: Environment, proj: ^Projectile) {
	proj.position = add_tuple(proj.position, proj.velocity)
	proj.velocity = add_tuple(proj.velocity, add_tuple(env.gravity, env.wind))
}

GridCoord :: struct {
	x: f64,
	y: f64,
}

draw_projectile :: proc() {
	pos := new_point(0, 0, 0)
	vel := normalize_tuple(new_vector(1, 1.8, 0))
	vel = mult_tuple(vel, 11.25)

	gravity := new_vector(0, -0.1, 0)
	wind := new_vector(-0.01, 0.0, 0)

	p := Projectile {
		pos,
		vel,
	}
	e := Environment {
		gravity,
		wind,
	}
	canvas := new_canvas(900, 500)
	white := new_color(1, 1, 1)

	max_x := 0.
	max_y := 0.
	pixels := [dynamic]GridCoord{}

	for {
		if p.position.y < 0 {
			break
		}

		if p.position.x > max_x {
			max_x = p.position.x
		}
		if p.position.y > max_y {
			max_y = p.position.y
		}
		append(&pixels, GridCoord{p.position.x, p.position.y})

		tick(e, &p)
	}

	for gc, i in pixels {
		x := x_to_width(gc.x, max_x)
		y := y_to_height(gc.y, max_y)

		write_pixel(&canvas, x, y, white)
	}

	ppm := canvas_to_ppm(canvas)
	os.write_entire_file("projectile.ppm", ppm)
}

x_to_width :: proc(x: f64, max: f64) -> int {
	max_with_offset := max * 0.9
	compressed := x * (max_with_offset / 900)
	return int(compressed)
}

y_to_height :: proc(y: f64, max: f64) -> int {
	max_with_offset := max * 0.9
	compressed := y * (max_with_offset / 500)
	reversed := 499 - int(compressed)
	negative := reversed < 0

	return reversed
}
