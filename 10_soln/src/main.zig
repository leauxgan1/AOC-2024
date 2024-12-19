const std = @import("std");
const print = std.debug.print;
const testing = false;

const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);
const FILE_LEN = if (testing) 8 else 52;
const FILE_WIDTH = if (testing) 8 else 52;

const Vec2 = struct {
    r: usize,
    c: usize,
};

const StateVec2 = struct {
    pos: Vec2,
    found: bool,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Collect lines from input

    var trailheads = std.ArrayList(Vec2).init(allocator);
    defer trailheads.deinit();
    var summits = std.ArrayList(StateVec2).init(allocator);
    defer summits.deinit();

    var lines: [FILE_LEN][FILE_WIDTH]u8 = undefined;
    for (0..FILE_LEN) |i| {
        const line_start = i * (FILE_LEN + 1);
        for (0..FILE_WIDTH) |j| {
            lines[i][j] = file_contents[line_start + j];
        }
    }
    // Collect trailhead positions
    for (lines, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == '0') {
                try trailheads.append(Vec2{ .r = i, .c = j });
            }
            if (char == '9') {
                try summits.append(StateVec2{
                    .pos = .{
                        .r = i,
                        .c = j,
                    },
                    .found = false,
                });
            }
        }
    }

    // print("Testing concat of {d} and {d} = {d}\n", .{ 0, 64, concatUint(0, 64) });
    { // Solution #1
        var answer_one: u64 = 0;
        // Depth first ascending climb
        for (trailheads.items) |trailhead| {
            // Set all summits to not found for this trailhead
            for (0..summits.items.len) |i| {
                var summit = &summits.items[i];
                summit.found = false;
            }
            var total_paths: u32 = 0;
            // print("Evaluating trailhead at ({d},{d})\n", .{ trailhead.r, trailhead.c });
            var stack = std.ArrayList(Vec2).init(allocator);
            defer stack.deinit();

            try checkAddNeighbors(trailhead, &lines, &stack);
            while (stack.items.len > 0) {
                // print("Content of stack: \n", .{});
                // printList(&stack);
                const pos = stack.pop();
                const elevation = lines[pos.r][pos.c];
                if (elevation == '9') {
                    // Find location of this summit in summit list
                    for (0..summits.items.len) |i| {
                        var summit = &summits.items[i];
                        if (summit.pos.r == pos.r and summit.pos.c == pos.c and summit.found == false) {
                            // print("Found path to 9 at {d},{d}\n", .{ pos.r, pos.c });
                            total_paths += 1;
                            summit.found = true;
                        }
                    }
                    for (0..summits.items.len) |j| {
                        // print("State of summit {d},{d}:  {any}\n", .{ summits.items[j].pos.r, summits.items[j].pos.c, summits.items[j].found });
                        _ = j;
                    }
                    continue;
                }
                try checkAddNeighbors(pos, &lines, &stack);
            }
            // print("    Total paths for this trailhead: {d}\n", .{total_paths});
            answer_one += total_paths;
        }

        print("Answer #1: {d}\n", .{answer_one});
    }
    { // Solution #2
        var answer_two: u64 = 0;
        for (trailheads.items) |trailhead| {
            // Set all summits to not found for this trailhead
            var total_paths: u32 = 0;
            // print("Evaluating trailhead at ({d},{d})\n", .{ trailhead.r, trailhead.c });
            var stack = std.ArrayList(Vec2).init(allocator);
            defer stack.deinit();

            try checkAddNeighbors(trailhead, &lines, &stack);
            while (stack.items.len > 0) {
                // print("Content of stack: \n", .{});
                // printList(&stack);
                const pos = stack.pop();
                const elevation = lines[pos.r][pos.c];
                if (elevation == '9') {
                    // Find location of this summit in summit list
                    for (0..summits.items.len) |i| {
                        const summit = summits.items[i];
                        if (summit.pos.r == pos.r and summit.pos.c == pos.c) {
                            // print("Found path to 9 at {d},{d}\n", .{ pos.r, pos.c });
                            total_paths += 1;
                        }
                    }
                    for (0..summits.items.len) |j| {
                        _ = j;
                        // print("State of summit {d},{d}:  {any}\n", .{ summits.items[j].pos.r, summits.items[j].pos.c, summits.items[j].found });
                    }
                    continue;
                }
                try checkAddNeighbors(pos, &lines, &stack);
            }
            // print("    Total paths for this trailhead: {d}\n", .{total_paths});
            answer_two += total_paths;
            // Search around the trailhead for its value + 1
        }
        print("Answer #2: {d}\n", .{answer_two});
    }
}

pub fn genericPrint(comptime T: type, items: std.ArrayList(T)) void {
    const printFn = generatePrintFn(T);
    printFn(items);
}
fn generatePrintFn(comptime T: type) fn (std.ArrayList(T)) void {
    return struct {
        fn printFunc(items: std.ArrayList(T)) void {
            for (items.items) |item| {
                // Specialized printing based on type
                switch (T) {
                    u8 => std.debug.print("{c}", .{item}), // Print as character
                    u32, u64 => std.debug.print("{d} ", .{item}), // Print as decimal
                    f32, f64 => std.debug.print("{:.2} ", .{item}), // Print with 2 decimal places
                    []const u8 => std.debug.print("{s} ", .{item}), // Print strings
                    else => std.debug.print("{any} ", .{item}), // Fallback for other types
                }
            }
            std.debug.print("\n", .{});
        }
    }.printFunc;
}

fn checkAddNeighbors(pos: Vec2, grid: *[FILE_LEN][FILE_WIDTH]u8, stack: *std.ArrayList(Vec2)) !void {
    const elevation = grid[pos.r][pos.c];
    const next_elevation = elevation + 1;
    // print("Checking for elevation {c}...\n", .{next_elevation});
    if (pos.r > 0) {
        const test_pos = Vec2{
            .r = pos.r - 1,
            .c = pos.c,
        };
        if (grid[pos.r - 1][pos.c] == next_elevation) {
            try stack.append(test_pos);
        }
    }
    if (pos.r < grid.len - 1) {
        const test_pos = Vec2{
            .r = pos.r + 1,
            .c = pos.c,
        };
        if (grid[test_pos.r][test_pos.c] == next_elevation) {
            try stack.append(test_pos);
        }
    }
    if (pos.c > 0) {
        const test_pos = Vec2{
            .r = pos.r,
            .c = pos.c - 1,
        };
        if (grid[test_pos.r][test_pos.c] == next_elevation) {
            try stack.append(test_pos);
        }
    }
    if (pos.c < grid[0].len - 1) {
        const test_pos = Vec2{
            .r = pos.r,
            .c = pos.c + 1,
        };
        if (grid[test_pos.r][test_pos.c] == next_elevation) {
            try stack.append(test_pos);
        }
    }
}

fn printList(list: *std.ArrayList(Vec2)) void {
    for (list.items) |item| {
        print("({d},{d}),", .{ item.r, item.c });
    }
    print("\n", .{});
}
