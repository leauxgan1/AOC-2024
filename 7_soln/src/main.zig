const std = @import("std");
const print = std.debug.print;
const testing = false;

const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Collect lines from input
    var lines = std.mem.tokenizeAny(u8, file_contents, "\n");

    { // Print Input
        // if (testing) {
        //     print("Test input: \n", .{});
        //     for (file_contents) |char| {
        //         print("{c}", .{char});
        //     }
        // }
    }
    // print("Testing concat of {d} and {d} = {d}\n", .{ 0, 64, concatUint(0, 64) });
    var answer_one: u64 = 0;
    var answer_two: u64 = 0;
    { // Solution #1
        while (lines.next()) |line| {
            // print("Testing equation -> {s}\n", .{line});
            var split = std.mem.splitAny(u8, line, ":");
            const target = split.next() orelse break;
            const target_val = try std.fmt.parseInt(u64, target, 10);
            // print("Searching for target: {d}\n", .{target_val});
            const operand_string = split.next() orelse break;

            var stack = std.ArrayList(u64).init(allocator);
            defer stack.deinit();
            try stack.append(0);

            var operands_split = std.mem.splitAny(u8, operand_string, " ");
            while (operands_split.next()) |operand| {
                if (operand.len < 1) {
                    continue;
                }
                // print("Adding and multiplying operand -> {s}\n", .{operand});
                const val_int = try std.fmt.parseInt(u64, operand, 10);

                const items = try stack.toOwnedSlice();
                defer allocator.free(items);

                for (items) |prev| {
                    if (prev > target_val) continue;
                    const sum = prev + val_int;
                    // print("    {d} + {d} = {d}\n", .{ prev, val_int, sum });
                    const prod = prev * val_int;
                    // print("    {d} * {d} = {d}\n", .{ prev, val_int, prod });
                    // print("      Found new possible sum: {d} and prod: {d}\n", .{ sum, prod });

                    try stack.append(sum);
                    if (prod > 0) { // Multiplying initial value will result in zero, do not include in stack
                        try stack.append(prod);
                    }
                }
            }
            // print("Remaining items in stack: \n", .{});
            for (stack.items) |item| {
                // print("Item: {d}\n", .{item});
                if (item == target_val) {
                    // print("    Found target!\n", .{});
                    answer_one += target_val;
                    break;
                }
            }
        }
        print("Answer #1: {d}\n", .{answer_one});
    }
    var lines_copy = std.mem.tokenizeAny(u8, file_contents, "\n");
    { // Solution #2
        while (lines_copy.next()) |line| {
            // print("Testing equation -> {s}\n", .{line});
            var split = std.mem.splitAny(u8, line, ":");
            const target = split.next() orelse break;
            const target_val = try std.fmt.parseInt(u64, target, 10);
            // print("Searching for target: {d}\n", .{target_val});
            const operand_string = split.next() orelse break;

            var stack = std.ArrayList(u64).init(allocator);
            defer stack.deinit();
            try stack.append(0);

            var operands_split = std.mem.splitAny(u8, operand_string, " ");
            while (operands_split.next()) |operand| {
                if (operand.len < 1) {
                    continue;
                }
                // print("Adding and multiplying operand -> {s}\n", .{operand});
                const val_int = try std.fmt.parseInt(u64, operand, 10);

                const items = try stack.toOwnedSlice();
                defer allocator.free(items);

                for (items) |prev| {
                    if (prev > target_val) continue;
                    const sum = prev + val_int;
                    // print("    {d} + {d} = {d}\n", .{ prev, val_int, sum });
                    const prod = prev * val_int;
                    // print("    {d} * {d} = {d}\n", .{ prev, val_int, prod });
                    const concated = concatUint(prev, val_int);
                    // print("      Found new possible sum: {d} and prod: {d}\n", .{ sum, prod });

                    try stack.append(sum);
                    if (prod > 0) { // Multiplying initial value will result in zero, do not include in stack
                        try stack.append(prod);
                    }
                    try stack.append(concated);
                }
            }
            // print("Remaining items in stack: \n", .{});
            for (stack.items) |item| {
                // print("Item: {d}\n", .{item});
                if (item == target_val) {
                    // print("    Found target!\n", .{});
                    answer_two += target_val;
                    break;
                }
            }
        }
        print("Answer #2: {d}\n", .{answer_two});
    }
}

fn printList(list: *std.ArrayList(u64)) void {
    print("{{", .{});
    for (list.items) |item| {
        print("{d},", .{item});
    }
    print("}}\n", .{});
}

fn concatUint(a: u64, b: u64) u64 {
    if (a == 0) {
        return b;
    }
    const digits = @as(u64, @intFromFloat(@floor(std.math.log10(@as(f32, @floatFromInt(b)))) + 1));
    const new_a = a * std.math.pow(u64, 10, digits);
    return new_a + b;
}
//
// test "correct concat of u64s" {
//     const a: u64 = 32;
//     const b: u64 = 2;
//     const c = concatUint(a, b);
//     const d = concatUint(b, a);
//     std.debug.assert(c == 322);
//     std.debug.assert(d == 232);
// }
