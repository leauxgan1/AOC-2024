const std = @import("std");
const print = std.debug.print;

const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const file_content = @embedFile(file_name);

pub fn main() !void {
    var elems_iter = std.mem.tokenizeAny(u8, file_content, "()\n");

    { // Solution #1
        var collecting = false;
        var prod_sum: i32 = 0;
        while (elems_iter.next()) |elem| {
            if (collecting) {
                // print("{s}\n", .{elem});

                // If the input to a current mul is another mul, discard the first but stay in the collecting state
                if (elem.len >= 3 and std.mem.eql(u8, elem[elem.len - 3 ..], "mul")) {
                    continue;
                }
                var pair = std.mem.splitAny(u8, elem, ",");
                const left = pair.next() orelse {
                    // print("Expected left val, found nothing :(\n", .{});
                    collecting = false;
                    continue;
                };
                const right = pair.next() orelse {
                    // print("Expected right val, found nothing :(\n", .{});
                    collecting = false;
                    continue;
                };
                const l = std.fmt.parseInt(i32, left, 10) catch |err| switch (err) {
                    else => {
                        // print("Error parsing left: {s}\n", .{left});
                        collecting = false;
                        continue;
                    },
                };
                const r = std.fmt.parseInt(i32, right, 10) catch |err| switch (err) {
                    else => {
                        // print("Error parsing right: {s}\n", .{right});
                        collecting = false;
                        continue;
                    },
                };

                prod_sum += l * r;
                // print("Collected {d} * {d} = {d} ... new total = {d}\n", .{ l, r, l * r, prod_sum });
                collecting = false;
            }
            if (elem.len >= 3 and std.mem.eql(u8, elem[elem.len - 3 ..], "mul")) {
                // print("{s}\n", .{elem});
                collecting = true;
            }
        }
        print("Answer #1: {d}\n", .{prod_sum});
    }
    elems_iter = std.mem.tokenizeAny(u8, file_content, "()\n");

    { // Solution #2
        var collecting = false;
        var enabled = true;
        var prod_sum: i32 = 0;
        while (elems_iter.next()) |elem| {
            if (collecting) {
                // print("{s}\n", .{elem});

                // If the input to a current mul is another mul, discard the first but stay in the collecting state
                if (elem.len >= 3 and std.mem.eql(u8, elem[elem.len - 3 ..], "mul")) {
                    continue;
                }
                var pair = std.mem.splitAny(u8, elem, ",");
                const left = pair.next() orelse {
                    // print("Expected left val, found nothing :(\n", .{});
                    collecting = false;
                    continue;
                };
                const right = pair.next() orelse {
                    // print("Expected right val, found nothing :(\n", .{});
                    collecting = false;
                    continue;
                };
                const l = std.fmt.parseInt(i32, left, 10) catch |err| switch (err) {
                    else => {
                        // print("Error parsing left: {s}\n", .{left});
                        collecting = false;
                        continue;
                    },
                };
                const r = std.fmt.parseInt(i32, right, 10) catch |err| switch (err) {
                    else => {
                        // print("Error parsing right: {s}\n", .{right});
                        collecting = false;
                        continue;
                    },
                };

                prod_sum += l * r;
                // print("Collected {d} * {d} = {d} ... new total = {d}\n", .{ l, r, l * r, prod_sum });
                collecting = false;
            }
            if (elem.len >= 2 and std.mem.eql(u8, elem[elem.len - 2 ..], "do")) {
                // Found do instruction
                // print("{s}\n", .{elem});
                // print("Do found: enabling future muls...\n", .{});
                enabled = true;
            } else if (elem.len >= 3 and std.mem.eql(u8, elem[elem.len - 3 ..], "mul")) {
                if (!enabled) {
                    // print("Found mul, but disabled, skipping...\n", .{});
                } else {
                    // print("{s}\n", .{elem});
                    // print("Found mul, and enabled, evaluating!...\n", .{});
                    collecting = true;
                }
            } else if (elem.len >= 5 and std.mem.eql(u8, elem[elem.len - 5 ..], "don't")) {
                // Found do instruction
                // print("{s}\n", .{elem});
                // print("Don't found: disabling future muls...\n", .{});
                enabled = false;
            }
        }
        print("Answer #2: {d}\n", .{prod_sum});
    }
}
