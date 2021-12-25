package main

import "core:mem"
import "core:fmt"

my_allocator_proc :: proc(
	allocator_data: rawptr,
	mode: mem.Allocator_Mode,
	size,
	alignment: int,
	old_memory: rawptr,
	old_size: int,
	loc := #caller_location,
) -> (
	[]byte,
	mem.Allocator_Error,
) {

	allocator := cast(^My_Allocator)allocator_data
	// if size > 1024 {
	// fmt.printf(
	// 	"{}/{} bytes. {} bytes. {}\n",
	// 	allocator.offset,
	// 	allocator.capactiy,
	// 	size,
	// 	loc,
	// )
	// }

	switch mode {
	case .Alloc:
		{
			// start := math.next_power_of_two(allocator.offset)
			start := allocator.offset
			end := start + size
			allocator.offset = end

			if allocator.offset + size > allocator.capactiy {
				fmt.println("No more memory")
				assert(false)
				return []byte{}, .Out_Of_Memory
			}

			return allocator.memory[start:end], nil
		}

	case .Resize:
		return mem.default_resize_bytes_align(
			mem.byte_slice(old_memory, old_size),
			size,
			alignment,
			my_allocator(allocator),
		)

	case .Free:
		return nil, .Mode_Not_Implemented

	case .Free_All:
		{
			allocator.offset = 0
			return nil, nil
		}

	case .Query_Features:
		fallthrough

	case .Query_Info:
		return nil, .Mode_Not_Implemented
	}

	return nil, nil
}


My_Allocator :: struct {
	offset:   int,
	capactiy: int,
	memory:   []byte,
}

my_allocator :: proc(allocator: ^My_Allocator) -> mem.Allocator {
	return mem.Allocator{procedure = my_allocator_proc, data = allocator}
}
