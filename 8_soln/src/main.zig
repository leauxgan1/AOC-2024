const std = @import("std");
const print = std.debug.print;
const testing = false;

const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);
const FILE_LEN = if (testing) 12 else 50;
const FILE_WIDTH = if (testing) 12 else 50;

const Vec2 = struct {
    x: isize,
    y: isize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Collect lines from input
    var lines_iter = std.mem.tokenizeAny(u8, file_contents, "\n");
    var lines_1 = std.ArrayList([]u8).init(allocator);
    var lines_2 = std.ArrayList([]u8).init(allocator);
    while (lines_iter.next()) |line| {
        try lines_1.append(try allocator.dupe(u8, line));
        try lines_2.append(try allocator.dupe(u8, line));
    }
    defer {
        for (0..lines_1.items.len) |i| {
            allocator.free(lines_1.items[i]);
        }
        lines_1.deinit();
        for (0..lines_2.items.len) |i| {
            allocator.free(lines_2.items[i]);
        }
        lines_2.deinit();
    }
    var antenna_map = std.AutoHashMap(u8, std.ArrayList(Vec2)).init(allocator);
    defer {
        var iter = antenna_map.valueIterator();
        while (iter.next()) |list| {
            list.deinit();
        }
        antenna_map.deinit();
    }

    //Populate antenna_map with characters as keys and their list of positions as values
    for (lines_1.items, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char != '.') {
                const pos = Vec2{ .x = @as(isize, @intCast(i)), .y = @as(isize, @intCast(j)) };
                if (antenna_map.contains(char)) {
                    var list = antenna_map.getPtr(char) orelse continue;
                    try list.append(pos);
                } else {
                    var new_list = std.ArrayList(Vec2).init(allocator);
                    try new_list.append(pos);
                    try antenna_map.put(char, new_list);
                }
            }
        }
    }
    { // Solution #1
        var answer_one: u64 = 0;
        var iter = antenna_map.valueIterator();
        while (iter.next()) |list| {
            for (0..list.items.len) |i| {
                const item = list.items[i];
                // Ensure this item is reached
                for (i + 1..list.items.len) |j| {
                    const other = list.items[j];

                    const diff = Vec2{ .x = item.x - other.x, .y = item.y - other.y };

                    const lnode = Vec2{ .x = item.x - 2 * diff.x, .y = item.y - 2 * diff.y };
                    // print("lnode of item {d}, {d} is {d},{d}\n", .{ item.x, item.y, lnode.x, lnode.y });

                    if (lnode.x >= 0 and lnode.x < FILE_LEN and lnode.y >= 0 and lnode.y < FILE_WIDTH) {
                        const x = @as(usize, @intCast(lnode.x));
                        const y = @as(usize, @intCast(lnode.y));
                        const val = lines_1.items[x][y];
                        if (val != '#') {
                            // print("Found antinode at row: {d}, col: {d}\n", .{ x, y });
                            answer_one += 1;
                            lines_1.items[x][y] = '#';
                        }
                    }
                    const rnode = Vec2{ .x = item.x + diff.x, .y = item.y + diff.y };
                    // print("rnode of item {d}, {d} is {d},{d}\n", .{ item.x, item.y, rnode.x, rnode.y });
                    if (rnode.x >= 0 and rnode.x < FILE_LEN and rnode.y >= 0 and rnode.y < FILE_WIDTH) {
                        const x = @as(usize, @intCast(rnode.x));
                        const y = @as(usize, @intCast(rnode.y));
                        const val = lines_1.items[x][y];
                        if (val != '#') {
                            // print("Found antinode at row: {d}, col: {d}\n", .{ x, y });
                            answer_one += 1;
                            lines_1.items[x][y] = '#';
                        }
                    }
                }
            }
        }
        print("Answer #1: {d}\n", .{answer_one});
    }

    { // Solution #2
        var answer_two: u64 = 0;
        var iter = antenna_map.valueIterator();
        while (iter.next()) |list| {
            for (0..list.items.len) |i| {
                const item = list.items[i];
                // Ensure this item is reached
                const first_val = lines_2.items[@as(usize, @intCast(item.x))][@as(usize, @intCast(item.y))];
                if (first_val != '#') {
                    answer_two += 1;
                    lines_2.items[@as(usize, @intCast(item.x))][@as(usize, @intCast(item.y))] = '#';
                }
                for (i + 1..list.items.len) |j| {
                    const other = list.items[j];

                    const diff = Vec2{ .x = item.x - other.x, .y = item.y - other.y };

                    var offset: isize = 1;
                    var anode = Vec2{ .x = 0, .y = 0 };
                    while (true) {
                        anode.x = item.x + (diff.x * offset);
                        anode.y = item.y + (diff.y * offset);

                        if (anode.x < 0 or anode.x >= FILE_LEN or anode.y < 0 or anode.y >= FILE_WIDTH) {
                            break;
                        } else {
                            const x = @as(usize, @intCast(anode.x));
                            const y = @as(usize, @intCast(anode.y));
                            const val = lines_2.items[x][y];
                            if (val != '#') {
                                // print("Found antinode at row: {d}, col: {d}\n", .{ x, y });
                                answer_two += 1;
                                lines_2.items[x][y] = '#';
                            }
                        }
                        offset += 1;
                    }
                    offset = 1;
                    while (true) {
                        anode.x = item.x - (diff.x * offset);
                        anode.y = item.y - (diff.y * offset);
                        if (anode.x >= 0 and anode.x < FILE_LEN and anode.y >= 0 and anode.y < FILE_WIDTH) {
                            const x = @as(usize, @intCast(anode.x));
                            const y = @as(usize, @intCast(anode.y));
                            const val = lines_2.items[x][y];
                            if (val != '#') {
                                // print("Found antinode at row: {d}, col: {d}\n", .{ x, y });
                                answer_two += 1;
                                lines_2.items[x][y] = '#';
                            }
                        } else {
                            break;
                        }
                        offset += 1;
                    }
                }
            }
        }
        // for (lines.items) |line| {
        //     print("{s}\n", .{line});
        // }
        print("Answer #2: {d}\n", .{answer_two});
    }
}
