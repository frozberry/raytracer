package main

Color :: struct {
	red: f64,
	green: f64,
	blue: f64,
}

new_color :: proc(red: f64, green: f64, blue: f64) -> Color {
	return Color{red, green, blue}
}

cmp_color :: proc(a: Color, b: Color) -> bool {
	red := cmp_float(a.red, b.red) 
	green := cmp_float(a.green, b.green) 
	blue := cmp_float(a.blue, b.blue) 
	return red && green && blue 
}

add_color :: proc(a: Color, b: Color) -> Color {
	t := Color{a.red + b.red, a.green + b.green, a.blue + b.blue}
	return t
}

sub_color :: proc(a: Color, b: Color) -> Color {
	t := Color{a.red - b.red, a.green - b.green, a.blue - b.blue}
	return t
}

negate_color :: proc(a: Color) -> Color {
	return Color{-a.red, -a.green, -a.blue}
}

mult_color :: proc {
	mult_color_by_scalar,
	mult_color_by_color,
}

@(private)
mult_color_by_scalar :: proc(a: Color, b: f64) -> Color {
	return Color{a.red * b, a.green * b, a.blue * b}
}

@(private)
mult_color_by_color :: proc(a: Color, b: Color) -> Color {
	return Color{a.red * b.red, a.green * b.green, a.blue * b.blue}
}

color_tests :: proc() {
	test_init()
	test_add_color()
	test_sub_color()
	test_mult_color()
	test_mult_color2()
}

/* -------------------------------------------------------------------------- */
/*                                    Test                                    */
/* -------------------------------------------------------------------------- */

test_init :: proc() {
	c := Color{-0.5, 0.4, 1.7}
	assert(cmp_float(c.red, -0.5))
	assert(cmp_float(c.green, 0.4))
	assert(cmp_float(c.blue, 1.7))
}

test_add_color :: proc() {
	a := new_color(0.9, 0.6, 0.75)
	b := new_color(0.7, 0.1, 0.25)
	actual := add_color(a, b)
	expected := new_color(1.6, 0.7, 1.0)
	assert(cmp_color(actual, expected))
}

test_sub_color :: proc() {
	a := new_color(0.9, 0.6, 0.75)
	b := new_color(0.7, 0.1, 0.25)
	actual := sub_color(a, b)
	expected := new_color(0.2, 0.5, 0.5)
	assert(cmp_color(actual, expected))
}

test_mult_color :: proc() {
	a := new_color(0.2, 0.3, 0.4)
	actual := mult_color(a, 2.0)
	expected := new_color(0.4, 0.6, 0.8)
	assert(cmp_color(actual, expected))
}

test_mult_color2 :: proc() {
	a := new_color(1, 0.2, 0.4)
	b := new_color(0.9, 1, 0.1)
	actual := mult_color(a, b)
	expected := new_color(0.9, 0.2, 0.04)
	assert(cmp_color(actual, expected))
}