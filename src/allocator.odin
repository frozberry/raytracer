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
	// if size > 1024000 {
	// fmt.printf(
	// 	"{}/{} bytes. {} bytes. {}\n",
	// 	allocator.offset,
	// 	allocator.capactiy,
	// 	size,
	// 	loc,
	// )
	// }

	if size == 1337 {
		fmt.println(allocator.offset, " bytes used before the loop")
	}


	switch mode {
	case .Alloc:
		{
			// start := math.next_power_of_two(allocator.offset)
			start := allocator.offset

			if start + size > allocator.capactiy {
				fmt.println("No more memory")
				assert(false)
				return []byte{}, .Out_Of_Memory
			}

			end := start + size
			allocator.offset = end

			if allocator.offset > MAX_MEM {
				MAX_MEM = allocator.offset
			}

			return allocator.memory[start:end], nil
		}

	case .Resize:
		fmt.println("resize called", loc)
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
			//I'm using this to only free everything in the loop, 
			// Found this value by logging on line 30
			allocator.offset = 24000512
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
