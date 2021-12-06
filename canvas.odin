package main
import "core:fmt"

Canvas :: struct {
	width: int,
	height: int,
	pixels: []Color,
}

new_canvas :: proc(width: int, height: int) -> Canvas {
	p := [dynamic]Color{}
	black := new_color(0, 0, 0)

	for i in 0..<width * height {
		append(&p, black)
	}
	return Canvas{width, height, p[:]}
}

write_pixel :: proc(canvas: ^Canvas, width: int, height: int, color: Color) {
	index := xy_to_index(canvas^, width, height)
	canvas.pixels[index] = color 
	return
}

pixel_at :: proc(canvas: Canvas, width: int, height: int) -> Color {
	index := xy_to_index(canvas, width, height)
	return canvas.pixels[index]
}

xy_to_index :: proc(canvas: Canvas, x: int, y: int) -> int{
	assert(x < canvas.width)
	assert(y < canvas.height)
	return (y * canvas.width)  + x
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

canvas_tests :: proc() {
	test_init_canvas()
	test_write_to_canvas()
	test_xy()
}

test_init_canvas :: proc() {
	c := new_canvas(10, 20)
	assert(c.width == 10)
	assert(c.height == 20)
	assert(len(c.pixels) == 200)

	for p in c.pixels {
		assert(cmp_color(p, Color{0, 0, 0}))
	}
}

test_write_to_canvas :: proc() {
	c := new_canvas(10, 20)
	red := new_color(1, 0, 0)
	write_pixel(&c, 2, 3, red)
	assert(cmp_color(pixel_at(c, 2, 3), red))
}

test_xy :: proc() {
	c := new_canvas(10, 20)

	assert(xy_to_index(c, 9, 19) == 199)
	assert(xy_to_index(c, 0, 0) == 0)
	assert(xy_to_index(c, 9, 0) == 9)
	assert(xy_to_index(c, 0, 1) == 10)
}
