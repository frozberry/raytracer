package main
import "core:fmt"
import "core:os"

Canvas :: struct {
	width:  int,
	height: int,
	pixels: []Color,
}

new_canvas :: proc(width: int, height: int) -> Canvas {
	size := width * height
	p := make([]Color, size)
	black := new_color(0, 0, 0)

	for i in 0 ..< width * height {
		p[i] = black
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

xy_to_index :: proc(canvas: Canvas, x: int, y: int) -> int {
	assert(x < canvas.width, int_to_string(x))
	assert(y < canvas.height)
	return (y * canvas.width) + x
}

color_to_string :: proc(color: Color) -> string {
	r := clamp_255(int(color.red * 255.0))
	g := clamp_255(int(color.green * 255.0))
	b := clamp_255(int(color.blue * 255.0))

	return fmt.tprintf("%v %v %v", r, g, b)
}

canvas_to_ppm :: proc(canvas: Canvas) -> []u8 {
	pixels := (canvas.width * canvas.height)


	// Each pixel could contain up to 9 bytes for RGB info, plus 3 for space/newline
	pixels_memory := pixels * (9 + 2)
	// Arbitary header size
	header := 100

	ppm_size := pixels_memory + header

	ppm := make([]u8, ppm_size)

	width := fmt.tprintf("%v ", canvas.width)
	height := fmt.tprintf("%v\n", canvas.height)

	i := 0

	append_string_to_array(&ppm, "P3\n", &i)
	append_string_to_array(&ppm, width, &i)
	append_string_to_array(&ppm, height, &i)
	append_string_to_array(&ppm, "255\n", &i)

	for p in canvas.pixels {
		append_string_to_array(&ppm, color_to_string(p), &i)
		append_string_to_array(&ppm, "\n", &i)
	}

	// This leads to 0s at the end because exact length depends on the colors.
	// Is it better to just use dynamic here?
	return ppm[0:i]
}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

canvas_tests :: proc() {
	test_init_canvas()
	test_write_to_canvas()
	test_xy()
	test_write_ppm()
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

test_write_ppm :: proc() {
	canvas := new_canvas(5, 3)

	a := new_color(1.5, 0, 0)
	b := new_color(0, 0.5, 0)
	c := new_color(-0.5, 0, 1)

	write_pixel(&canvas, 0, 0, a)
	write_pixel(&canvas, 2, 1, b)
	write_pixel(&canvas, 4, 2, c)

	ppm := canvas_to_ppm(canvas)
	expected := []u8{
		80,
		51,
		10,
		53,
		32,
		51,
		10,
		50,
		53,
		53,
		10,
		50,
		53,
		53,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		49,
		50,
		55,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		48,
		10,
		48,
		32,
		48,
		32,
		50,
		53,
		53,
		10,
	}

	assert(cmp_slice(ppm, expected))
}
