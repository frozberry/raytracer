package main

import "core:fmt"
import "core:math"

Material :: struct {
	color:     Color,
	ambient:   f64,
	diffuse:   f64,
	specular:  f64,
	shininess: f64,
}

new_material :: proc(
	color := Color{1, 1, 1},
	ambient := 0.1,
	diffuse := 0.9,
	specular := 0.9,
	shininess := 200.0,
) -> Material {
	neg := ambient < 0 || diffuse < 0 || specular < 0 || shininess < 0
	assert(!neg, "Material only accepts non-negative values")
	return Material{color, ambient, diffuse, specular, shininess}
}

cmp_material :: proc(a: Material, b: Material) -> bool {
	color := cmp_color(a.color, b.color)
	amb := cmp_float(a.ambient, b.ambient)
	dif := cmp_float(a.diffuse, b.diffuse)
	spec := cmp_float(a.specular, b.specular)
	shin := cmp_float(a.shininess, b.shininess)
	return color && amb && dif && spec && shin
}

lighting :: proc(
	material: Material,
	light: PointLight,
	point: Tuple,
	eyev: Tuple,
	normalv: Tuple,
) -> Color {
	effective_color := mult_color(material.color, light.intensity)

	direction := sub_tuple(light.position, point)
	lightv := normalize_tuple(direction)

	ambient := mult_color_by_scalar(effective_color, material.ambient)

	light_dot_normal := dot(lightv, normalv)

	diffuse: Color
	specular: Color


	if light_dot_normal < 0 {
		diffuse := new_color(0, 0, 0)
		specular := new_color(0, 0, 0)
	} else {
		diffuse = mult_color_by_scalar(
			mult_color(effective_color, material.diffuse),
			light_dot_normal,
		)

		reflectv := reflect(negate_tuple(lightv), normalv)
		reflect_dot_eye := dot(reflectv, eyev)

		if reflect_dot_eye < 0 {
			specular = new_color(0, 0, 0)
		} else {
			factor := math.pow(reflect_dot_eye, material.shininess)
			specular = mult_color_by_scalar(mult_color(light.intensity, material.specular), factor)
		}

	}
	return add_color(add_color(ambient, diffuse), specular)

}

/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */

material_tests :: proc() {
	test_new_material()
	test_lighting_between_eye_and_surface()
	test_ligting_with_eye_and_surface_45()
	test_ligthing_eye_opposite_surface_45()
	test_ligthing_with_eye_in_reflection_path()
	test_light_behind_surface()
}

test_new_material :: proc() {
	m := new_material()
	assert(cmp_color(m.color, new_color(1, 1, 1)))
	assert(cmp_float(m.ambient, 0.1))
	assert(cmp_float(m.diffuse, 0.9))
	assert(cmp_float(m.specular, 0.9))
	assert(cmp_float(m.shininess, 200.0))
}

test_lighting_between_eye_and_surface :: proc() {
	m := new_material()
	position := new_point(0, 0, 0)

	eyev := new_vector(0, 0, -1)
	normalv := new_vector(0, 0, -1)
	light := new_point_light(new_point(0, 0, -10), new_color(1, 1, 1))

	result := lighting(m, light, position, eyev, normalv)
	assert(cmp_color(result, new_color(1.9, 1.9, 1.9)))
}

test_ligting_with_eye_and_surface_45 :: proc() {
	m := new_material()
	position := new_point(0, 0, 0)

	eyev := new_vector(0, root2 / 2, -root2 / 2)
	normalv := new_vector(0, 0, -1)
	light := new_point_light(new_point(0, 0, -10), new_color(1, 1, 1))

	result := lighting(m, light, position, eyev, normalv)
	assert(cmp_color(result, new_color(1.0, 1.0, 1.0)))
}

test_ligthing_eye_opposite_surface_45 :: proc() {
	m := new_material()
	position := new_point(0, 0, 0)

	eyev := new_vector(0, 0, -1)
	normalv := new_vector(0, 0, -1)
	light := new_point_light(new_point(0, 10, -10), new_color(1, 1, 1))

	result := lighting(m, light, position, eyev, normalv)
	assert(cmp_color(result, new_color(0.7364, 0.7364, 0.7364)))
}

test_ligthing_with_eye_in_reflection_path :: proc() {
	m := new_material()
	position := new_point(0, 0, 0)

	eyev := new_vector(0, -root2 / 2, -root2 / 2)
	normalv := new_vector(0, 0, -1)
	light := new_point_light(new_point(0, 10, -10), new_color(1, 1, 1))

	result := lighting(m, light, position, eyev, normalv)
	assert(cmp_color(result, new_color(1.6364, 1.6364, 1.6364)))
}

test_light_behind_surface :: proc() {
	m := new_material()
	position := new_point(0, 0, 0)

	eyev := new_vector(0, 0, -1)
	normalv := new_vector(0, 0, -1)
	light := new_point_light(new_point(0, 0, 10), new_color(1, 1, 1))

	result := lighting(m, light, position, eyev, normalv)
	assert(cmp_color(result, new_color(0.1, 0.1, 0.1)))
}
