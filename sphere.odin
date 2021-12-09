package main
import "core:math/rand"

Sphere :: struct {
	id: u64,
}

new_sphere :: proc() -> Sphere {
	return Sphere{rand.uint64()}
}