package main
import "core:fmt"

Matrix :: struct {
	rows:    int,
	cols:    int,
	entries: []f64,
}

new_matrix :: proc {
	new_matrix_with_entry,
	new_empty_matrix,
}

new_matrix_with_entry :: proc(rows: int, cols: int, entries: []f64) -> Matrix {
	assert(
		len(entries) == rows * cols,
		"Length of matrix entries should be equal to cols * rows",
	)

	return Matrix{rows, cols, entries}
}

new_empty_matrix :: proc(rows: int, cols: int) -> Matrix {
	e := [dynamic]f64{}
	for i in 0 ..< rows * cols {
		append(&e, 0)
	}

	return Matrix{rows, cols, e[:]}
}

// This needs memory allocation since the entries array is not passed in param
// Still unclear why new_matrix() works without allocation

// This causes draw 3D sphere to break, the transform matrix changes
new_identity_matrix :: proc() -> Matrix {
	e := make([]f64, 16, context.allocator)
	e[0] = 1.0
	e[5] = 1.0
	e[10] = 1.0
	e[15] = 1.0

	return new_matrix(4, 4, e)
}

write_matrix :: proc(m: ^Matrix, row: int, col: int, write: f64) {
	assert(row <= m.rows && col <= m.cols, "You are writing to a row/col that doesn't exist")
	m.entries[row * m.cols + col] = write
	return
}

read_matrix :: proc(m: Matrix, row: int, col: int) -> f64 {
	assert(row <= m.rows && col <= m.cols, "You are reading a row/col that doesn't exist")
	return m.entries[row * m.cols + col]
}

index_to_row_col :: proc(m: Matrix, i: int) -> (row: int, col: int) {
	c := i % m.cols
	r := i / m.cols
	return r, c
}

cmp_matrix :: proc(a: Matrix, b: Matrix) -> bool {
	return cmp_slice_f64(a.entries, b.entries)
}

// Only needed for 4x4.4x4
mult_matrix :: proc(m1: Matrix, m2: Matrix) -> Matrix {
	m := new_empty_matrix(4, 4)

	for row in 0 ..< 4 {
		for col in 0 ..< 4 {
			a := read_matrix(m1, row, 0) * read_matrix(m2, 0, col)
			b := read_matrix(m1, row, 1) * read_matrix(m2, 1, col)
			c := read_matrix(m1, row, 2) * read_matrix(m2, 2, col)
			d := read_matrix(m1, row, 3) * read_matrix(m2, 3, col)
			entry := a + b + c + d

			write_matrix(&m, row, col, entry)
		}
	}
	return m
}

mult_matrix_by_tuple :: proc(m: Matrix, t: Tuple) -> Tuple {
	a := read_matrix(m, 0, 0) * t.x + read_matrix(m, 0, 1) * t.y + read_matrix(m, 0, 2) * t.z +
      read_matrix(m, 0, 3) * t.w
	b := read_matrix(m, 1, 0) * t.x + read_matrix(m, 1, 1) * t.y + read_matrix(m, 1, 2) * t.z +
      read_matrix(m, 1, 3) * t.w
	c := read_matrix(m, 2, 0) * t.x + read_matrix(m, 2, 1) * t.y + read_matrix(m, 2, 2) * t.z +
      read_matrix(m, 2, 3) * t.w
	d := read_matrix(m, 3, 0) * t.x + read_matrix(m, 3, 1) * t.y + read_matrix(m, 3, 2) * t.z +
      read_matrix(m, 3, 3) * t.w
	return Tuple{a, b, c, d}
}

transpose_matrix :: proc(m: Matrix) -> Matrix {
	new := new_matrix(m.rows, m.cols)

	for row in 0 ..< m.rows {
		for col in 0 ..< m.cols {
			write_matrix(&new, row, col, read_matrix(m, col, row))
		}
	}
	return new
}

print_matrix :: proc(m: Matrix) {
	for i in 0 ..< m.rows {
		for j in 0 ..< m.cols {
			fmt.print(read_matrix(m, i, j), " ")
		}
		fmt.println("")
	}
	fmt.println("")
}

determinate :: proc(m: Matrix) -> f64 {
	if m.rows == 2 && m.cols == 2 {
		return m.entries[0] * m.entries[3] - m.entries[1] * m.entries[2]
	}

	det := 0.0
	for col in 0 ..< m.cols {
		det += read_matrix(m, 0, col) * cofactor(m, 0, col)
	}
	return det
}

// Probably could be optimised
submatrix :: proc(m: Matrix, row: int, col: int) -> Matrix {
	assert(row <= m.rows && col <= m.cols, "row or col is not in matrix")

	e := [dynamic]f64{}
	for v, i in m.entries {
		r, c := index_to_row_col(m, i)
		if r == row || c == col {
			continue
		}
		append(&e, v)
	}

	return new_matrix(m.rows - 1, m.cols - 1, e[:])
}

minor :: proc(m: Matrix, row: int, col: int) -> f64 {
	s := submatrix(m, row, col)
	return determinate(s)
}

cofactor :: proc(m: Matrix, row: int, col: int) -> f64 {
	m := minor(m, row, col)
	if (row + col) % 2 == 0 {
		return m
	} else {
		return -(m)
	}
}

is_ivertible :: proc(m: Matrix) -> bool {
	return !cmp_float(determinate(m), 0)
}

inverse_matrix :: proc(m: Matrix) -> (Matrix, bool) {
	if !is_ivertible(m) do return new_matrix(4, 4), false

	m2 := new_matrix(m.rows, m.cols)

	determinate := determinate(m)

	for row in 0 ..< m.rows {
		for col in 0 ..< m.cols {
			cofactor := cofactor(m, row, col)
			val := cofactor / determinate

			// col, row transposes
			write_matrix(&m2, col, row, val)
		}
	}

	return m2, false
}


/* -------------------------------------------------------------------------- */
/*                                    Tests                                   */
/* -------------------------------------------------------------------------- */
matrix_tests :: proc() {
	test_read_matrix()
	test_write_matrix()
	test_two_by_two_matrix()
	test_three_by_three_matrix()
	test_index_to_rc()
	test_cmp_matrix()
	test_mult_matrix()
	test_mult_matrix_by_tuple()
	test_identity()
	test_transpose()
	test_tranpose_identity()
	test_determinate_two_by_two()
	test_submatrix()
	test_submatrix_2()
	test_minor()
	test_cofactor()
	test_determinate_three()
	test_determinate_four()
	test_inversion()
	test_inversion_2()
	test_inverse_returns_to_original()

	return
}

test_read_matrix :: proc() {
	e := []f64{1, 2, 3, 4, 5.5, 6.5, 7.5, 8.5, 9, 10, 11, 12, 13.5, 14.5, 15.5, 16.5}
	m := new_matrix(4, 4, e)

	assert(cmp_float(read_matrix(m, 0, 0), 1))
	assert(cmp_float(read_matrix(m, 0, 3), 4))
	assert(cmp_float(read_matrix(m, 1, 0), 5.5))
	assert(cmp_float(read_matrix(m, 1, 2), 7.5))
	assert(cmp_float(read_matrix(m, 2, 2), 11))
	assert(cmp_float(read_matrix(m, 3, 0), 13.5))
	assert(cmp_float(read_matrix(m, 3, 2), 15.5))
}

test_write_matrix :: proc() {
	m := new_matrix(4, 4)

	write_matrix(&m, 0, 0, 5)
	assert(cmp_float(read_matrix(m, 0, 0), 5))

	write_matrix(&m, 3, 3, 5)
	assert(cmp_float(read_matrix(m, 3, 3), 5))
}

test_index_to_rc :: proc() {
	m := new_matrix(4, 4)
	r1, c1 := index_to_row_col(m, 0)
	r2, c2 := index_to_row_col(m, 1)
	r3, c3 := index_to_row_col(m, 2)
	r4, c4 := index_to_row_col(m, 3)
	r5, c5 := index_to_row_col(m, 4)
	r6, c6 := index_to_row_col(m, 15)

	assert(r1 == 0 && c1 == 0)
	assert(r2 == 0 && c2 == 1)
	assert(r3 == 0 && c3 == 2)
	assert(r4 == 0 && c4 == 3)
	assert(r5 == 1 && c5 == 0)
	assert(r6 == 3 && c6 == 3)
}

test_two_by_two_matrix :: proc() {
	e := []f64{-3, 5, 1, -2}
	m := new_matrix(2, 2, e)

	assert(cmp_float(read_matrix(m, 0, 0), -3))
	assert(cmp_float(read_matrix(m, 0, 1), 5))
	assert(cmp_float(read_matrix(m, 1, 0), 1))
	assert(cmp_float(read_matrix(m, 1, 1), -2))
}

test_three_by_three_matrix :: proc() {
	e := []f64{-3, 5, 0, 1, -2, -7, 0, 1, 1}
	m := new_matrix(3, 3, e)

	assert(cmp_float(read_matrix(m, 0, 0), -3))
	assert(cmp_float(read_matrix(m, 1, 1), -2))
	assert(cmp_float(read_matrix(m, 2, 2), 1))
}

test_cmp_matrix :: proc() {
	e := []f64{1, 2, 3, 4, 5, 6, 7, 8, 9}
	m := new_matrix(3, 3, e)

	e1 := []f64{1, 2, 3, 4, 5, 6, 7, 8, 9}
	m1 := new_matrix(3, 3, e1)

	e2 := []f64{1, 2, 3, 4, 5, 6, 7, 8, 9000}
	m2 := new_matrix(3, 3, e2)

	e3 := []f64{1, 2, 3, 4}
	m3 := new_matrix(2, 2, e3)

	e4 := []f64{1, 2, 3, 4, 5, 6, 7, 8, 9.000001}
	m4 := new_matrix(3, 3, e4)

	assert(cmp_matrix(m, m1))
	assert(!cmp_matrix(m, m2))
	assert(!cmp_matrix(m, m3))
	assert(cmp_matrix(m, m4))
}

test_mult_matrix :: proc() {
	e1 := []f64{1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2}
	m1 := new_matrix(4, 4, e1)

	e2 := []f64{-2, 1, 2, 3, 3, 2, 1, -1, 4, 3, 6, 5, 1, 2, 7, 8}
	m2 := new_matrix(4, 4, e2)

	e3 := []f64{20, 22, 50, 48, 44, 54, 114, 108, 40, 58, 110, 102, 16, 26, 46, 42}
	m3 := new_matrix(4, 4, e3)

	assert(cmp_matrix(m3, mult_matrix(m1, m2)))
}

test_mult_matrix_by_tuple :: proc() {
	e := []f64{1, 2, 3, 4, 2, 4, 4, 2, 8, 6, 4, 1, 0, 0, 0, 1}
	m := new_matrix(4, 4, e)

	t := new_tuple(1, 2, 3, 1)

	actual := mult_matrix_by_tuple(m, t)
	expected := new_tuple(18, 24, 33, 1)

	assert(cmp_tuple(actual, expected))
}

test_identity :: proc() {
	e := []f64{1, 2, 3, 4, 2, 4, 4, 2, 8, 6, 4, 1, 0, 0, 0, 1}
	m := new_matrix(4, 4, e)
	i := new_identity_matrix()

	outcome := mult_matrix(m, i)
	assert(cmp_matrix(outcome, m))
}

test_transpose :: proc() {
	a := new_matrix(4, 4, []f64{0, 9, 3, 0, 9, 8, 0, 8, 1, 8, 5, 3, 0, 0, 5, 8})
	actual := transpose_matrix(a)
	expected := new_matrix(4, 4, []f64{0, 9, 1, 0, 9, 8, 8, 0, 3, 0, 5, 5, 0, 8, 3, 8})
	assert(cmp_matrix(actual, expected))
}

test_tranpose_identity :: proc() {
	i := new_identity_matrix()
	t := transpose_matrix(i)

	assert(cmp_matrix(t, new_identity_matrix()))
}

test_determinate_two_by_two :: proc() {
	a := new_matrix(2, 2, []f64{1, 5, -3, 2})
	assert(cmp_float(determinate(a), 17))
}

test_submatrix :: proc() {
	a := new_matrix(3, 3, []f64{1, 5, 0, -3, 2, 7, 0, 6, -3})
	expected := new_matrix(2, 2, []f64{-3, 2, 0, 6})
	assert(cmp_matrix(expected, submatrix(a, 0, 2)))
}

test_submatrix_2 :: proc() {
	a := new_matrix(4, 4, []f64{-6, 1, 1, 6, -8, 5, 8, 6, -1, 0, 8, 2, -7, 1, -1, 1})
	expected := new_matrix(3, 3, []f64{-6, 1, 6, -8, 8, 6, -7, -1, 1})

	assert(cmp_matrix(expected, submatrix(a, 2, 1)))
}

test_minor :: proc() {
	a := new_matrix(3, 3, []f64{3, 5, 0, 2, -1, -7, 6, -1, 5})
	expected := 25.0

	assert(cmp_float(expected, minor(a, 1, 0)))

	b := submatrix(a, 1, 0)
	assert(cmp_float(expected, determinate(b)))
}

test_cofactor :: proc() {
	a := new_matrix(3, 3, []f64{3, 5, 0, 2, -1, -7, 6, -1, 5})

	assert(cmp_float(-12, minor(a, 0, 0)))
	assert(cmp_float(-12, cofactor(a, 0, 0)))

	assert(cmp_float(25, minor(a, 1, 0)))
	assert(cmp_float(-25, cofactor(a, 1, 0)))
}

test_determinate_three :: proc() {
	a := new_matrix(3, 3, []f64{1, 2, 6, -5, 8, -4, 2, 6, 4})
	assert(cmp_float(56, cofactor(a, 0, 0)))
	assert(cmp_float(12, cofactor(a, 0, 1)))
	assert(cmp_float(-46, cofactor(a, 0, 2)))
	assert(cmp_float(-196, determinate(a)))
}


test_determinate_four :: proc() {
	a := new_matrix(4, 4, []f64{-2, -8, 3, 5, -3, 1, 7, 3, 1, 2, -9, 6, -6, 7, 7, -9})
	assert(cmp_float(690, cofactor(a, 0, 0)))
	assert(cmp_float(447, cofactor(a, 0, 1)))
	assert(cmp_float(210, cofactor(a, 0, 2)))
	assert(cmp_float(51, cofactor(a, 0, 3)))
	assert(cmp_float(-4071, determinate(a)))
}

test_inversion :: proc() {
	a := new_matrix(4, 4, []f64{-5, 2, 6, -8, 1, -5, 1, 8, 7, 7, -6, -7, 1, -3, 7, 4})
	b, err := inverse_matrix(a)

	assert(cmp_float(cofactor(a, 2, 3), -160))
	assert(cmp_float(-(160.0 / 532.0), read_matrix(b, 3, 2)))
	assert(cmp_float(cofactor(a, 3, 2), 105))

	assert(cmp_float((105.0 / 532.0), read_matrix(b, 2, 3)))

	expected_b := new_matrix(
		4,
		4,
		[]f64{
			0.21805,
			0.45113,
			0.24060,
			-0.04511,
			-0.80827,
			-1.45677,
			-0.44361,
			0.52068,
			-0.07895,
			-0.22368,
			-0.05263,
			0.19737,
			-0.52256,
			-0.81391,
			-0.30075,
			0.30639,
		},
	)

	assert(cmp_matrix(b, expected_b))
}

test_inversion_2 :: proc() {
	a := new_matrix(4, 4, []f64{8, -5, 9, 2, 7, 5, 6, 1, -6, 0, 9, 6, -3, 0, -9, -4})
	expected := new_matrix(
		4,
		4,
		[]f64{
			-0.15385,
			-0.15385,
			-0.28205,
			-0.53846,
			-0.07692,
			0.12308,
			0.02564,
			0.03077,
			0.35897,
			0.35897,
			0.43590,
			0.92308,
			-0.69231,
			-0.69231,
			-0.76923,
			-1.92308,
		},
	)
	actual, _ := inverse_matrix(a)

	assert(cmp_matrix(actual, expected))
}

test_inverse_returns_to_original :: proc() {
	a := new_matrix(4, 4, []f64{3, -9, 7, 3, 3, -8, 2, -9, -4, 4, 4, 1, -6, 5, -1, 1})
	b := new_matrix(4, 4, []f64{8, 2, 2, 2, 3, -1, 7, 0, 7, 0, 5, 4, 6, -2, 0, 5})

	c := mult_matrix(a, b)
	ib, _ := inverse_matrix(b)

	actual := mult_matrix(c, ib)
	assert(cmp_matrix(actual, a))
}
