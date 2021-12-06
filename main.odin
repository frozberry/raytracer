package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"

Projectile :: struct {
	position: Tuple,
	velocity: Tuple,
}

Environment :: struct {
	gravity: Tuple,
	wind: Tuple,
}

tick :: proc(env: Environment, proj: ^Projectile) {
	proj.position = add_tuple(proj.position, proj.velocity) 
	proj.velocity = add_tuple(env.gravity, env.wind)
}

main :: proc() {
	tuple_tests()

	p := Projectile{new_point(0, 1, 0), normalize_tuple(new_vector(1, 1, 0))}
	e := Environment{new_vector(0, -0.1, 0), new_vector(-0.01, 0, 0)}

	for i in 0..100 {
		tick(e, &p)
		fmt.println("x: ", p.position.x)
		fmt.println("y: ", p.position.y)
		fmt.println("")
	}
}
