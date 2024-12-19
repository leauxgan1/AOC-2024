const std = @import("std");
const print = std.debug.print;
const testing = false;

const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);

const DiskState = union(enum) {
    filled: usize,
    empty: u0,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Collect lines from input
    var mapped_1 = std.ArrayList(DiskState).init(allocator);
    defer mapped_1.deinit();
    var mapped_2 = std.ArrayList(DiskState).init(allocator);
    defer mapped_2.deinit();

    for (file_contents, 0..) |char, i| {
        if (char == '\n') {
            continue;
        }
        const num_val = try std.fmt.parseInt(u32, &[_]u8{char}, 10);
        if (i % 2 == 1) {
            for (0..num_val) |_| {
                try mapped_1.append(.{ .empty = 0 });
                try mapped_2.append(.{ .empty = 0 });
            }
        } else {
            for (0..num_val) |_| {
                // print("appending: {d}\n", .{i});
                try mapped_1.append(.{ .filled = @divTrunc(i, 2) });
                try mapped_2.append(.{ .filled = @divTrunc(i, 2) });
            }
        }
    }
    // print("Expanded:\n", .{});
    // printList(&mapped);

    { // Solution #1
        var answer_one: u64 = 0;
        var left: usize = 0;
        var right: usize = mapped_1.items.len - 1;
        while (left < right) {
            switch (mapped_1.items[left]) {
                .empty => {
                    //Ensure the rightmost position is filled
                    switch (mapped_1.items[right]) {
                        .empty => {
                            right -= 1;
                            continue;
                        },
                        .filled => {},
                    }
                    mapped_1.items[left] = mapped_1.items[right];
                    mapped_1.items[right] = .{ .empty = 0 };
                },
                else => {},
            }
            left += 1;
        }

        // print("Final value of left: {d}\n", .{left});
        // print("Final value of right: {d}\n", .{right});
        // print("Processed:\n", .{});
        // printList(&mapped);
        for (0..mapped_1.items.len) |i| {
            switch (mapped_1.items[i]) {
                .filled => |val| {
                    const prod = i * val;
                    answer_one += prod;
                },
                else => {},
            }
        }
        print("Answer #1: {d}\n", .{answer_one});
    }

    { // Solution #2
        var answer_two: u64 = 0;
        var filled_idx: usize = mapped_2.items.len - 1; // Set to the position to the left of the last emptied file

        // printList(&mapped_2);
        while (filled_idx > 0) {
            // Find start and end of appropriately sized file
            var right_file_bound: usize = filled_idx; // Start searching from the rightmost position since we could have left a file behind previously
            var left_file_bound: usize = 0; // To be set in the loop body
            while (right_file_bound > 0 and mapped_2.items[right_file_bound] == .empty) {
                right_file_bound -= 1;
            }
            // print("Found start of rightmost file at {d}\n", .{right_file_bound});
            // Found start of rightmost file
            const val = mapped_2.items[right_file_bound].filled;

            // Start leftmost index of file at rightmost
            left_file_bound = right_file_bound;
            while (left_file_bound > 0 and mapped_2.items[left_file_bound - 1] == .filled and mapped_2.items[left_file_bound - 1].filled == val) {
                left_file_bound -= 1;
            }
            // print("Found end of rightmost file at {d}\n", .{left_file_bound});
            const file_space = (right_file_bound - left_file_bound) + 1;
            // Collected left and right bound of file
            // print("Found left and right file bound: {d},{d} with size {d}\n", .{ left_file_bound, right_file_bound, file_space });
            var left_empty_bound: usize = 0;
            var right_empty_bound: usize = 0;
            // Find the left bound of an empty space
            // If it is not large enough, look for a further empty space
            while (left_empty_bound < left_file_bound) {
                while (left_empty_bound < left_file_bound and mapped_2.items[left_empty_bound] == .filled) {
                    left_empty_bound += 1;
                }
                if (left_empty_bound >= left_file_bound) {
                    break;
                }
                right_empty_bound = left_empty_bound;
                while (right_empty_bound < left_file_bound and mapped_2.items[right_empty_bound + 1] == .empty) {
                    right_empty_bound += 1;
                }
                if (right_empty_bound >= left_file_bound) {
                    break;
                }

                const empty_space = (right_empty_bound - left_empty_bound) + 1;
                if (empty_space >= file_space) {
                    break;
                } else {
                    // print("Empty space not large enough ({d}), searching further\n", .{empty_space});
                }
                left_empty_bound = right_empty_bound + 1;
            }
            if (left_empty_bound >= left_file_bound or right_empty_bound >= left_file_bound) {
                // print("Was not able to find a suitable space for file {d},{d}\n", .{ left_file_bound, right_file_bound });
                if (left_file_bound > 0) {
                    filled_idx = left_file_bound - 1;
                } else {
                    break;
                }
                continue;
            }
            // print("Found left and right empty bound: {d},{d}\n", .{ left_empty_bound, right_empty_bound });
            // FINALLY we know this file is ready to be moved
            for (0..file_space) |i| {
                mapped_2.items[left_empty_bound + i] = mapped_2.items[left_file_bound + i];
                mapped_2.items[left_file_bound + i] = .{ .empty = 0 };
            }
            // print("State of disk after move: \n", .{});
            // printList(&mapped_2);
            if (left_file_bound > 0) {
                filled_idx = left_file_bound - 1;
            }
        }

        // print("Final value of left: {d}\n", .{left});
        // print("Final value of right: {d}\n", .{right});
        // print("Processed:\n", .{});
        // printList(&mapped_2);
        for (0..mapped_2.items.len) |i| {
            switch (mapped_2.items[i]) {
                .filled => |val| {
                    const prod = i * val;
                    answer_two += prod;
                },
                else => {},
            }
        }
        print("Answer #2: {d}\n", .{answer_two});
    }
}

fn printList(list: *std.ArrayList(DiskState)) void {
    for (list.items) |char| {
        switch (char) {
            .filled => |val| print("{d}", .{val}),
            else => print(".", .{}),
        }
    }
    print("\n", .{});
}
