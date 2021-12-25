package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:math"
import "core:time"
import "core:mem"

MAX_MEM: int

main :: proc() {
	TOTAL_MEMORY := mem.megabytes(35)

	ma: My_Allocator
	ma.capactiy = TOTAL_MEMORY

	defer {
		fmt.printf("Allocated {}mb out of {}\n", ma.offset / 1000_000, ma.capactiy / 1000_000)
	}

	err: mem.Allocator_Error
	ma.memory, err = mem.alloc_bytes(TOTAL_MEMORY)

	assert(err == .None, "Unable to allocate memory")
	context.allocator = my_allocator(&ma)


	// tuple_tests()
	// color_tests()
	// canvas_tests()
	// matrix_tests()
	// transformation_tests()
	// ray_tests()
	// intersection_tests()
	// sphere_tests()
	// lights_tests()
	// material_tests()


	draw_sphere_3d(1000)
	fmt.println("Maximum memory used at any point in the program", MAX_MEM, "b")
}
