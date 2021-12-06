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
	color_tests()

}
