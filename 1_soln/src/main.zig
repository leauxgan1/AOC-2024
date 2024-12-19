const std = @import("std");
const print = std.debug.print;
const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);

const FILE_LEN = if (testing) 6 else 1000;

pub fn main() !void {
    var left_list: [FILE_LEN]u32 = undefined;
    var right_list: [FILE_LEN]u32 = undefined;

    var idx: usize = 0;
    var iter = std.mem.tokenizeAny(u8, file_contents, "\n");
    while (iter.next()) |substring| {
        var split = std.mem.splitSequence(u8, substring, "   ");
        const left = split.next() orelse unreachable;
        const left_val = try std.fmt.parseInt(u32, left, 10);
        left_list[idx] = left_val;
        const right = split.next() orelse unreachable;
        const right_val = try std.fmt.parseInt(u32, right, 10);
        right_list[idx] = right_val;
        idx += 1;
    }

    std.mem.sort(u32, &left_list, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, &right_list, {}, comptime std.sort.asc(u32));
    { // Solution #1
        var answer_one: usize = 0;
        for (0..FILE_LEN) |i| {
            const left = left_list[i];
            const right = right_list[i];

            const diff = if (left > right) left - right else right - left;
            answer_one += diff;
        }
        print("Answer #1: {d}\n", .{answer_one});
    }
    { // Solution #2
        var answer_two: usize = 0;
        var i: usize = 0;
        while (i < FILE_LEN) {
            var similarity: u32 = 0;
            for (0..FILE_LEN) |j| {
                if (left_list[i] < right_list[j]) break;
                if (left_list[i] == right_list[j]) {
                    similarity += 1;
                }
            }
            answer_two += left_list[i] * similarity;
            i += 1;
        }
        print("Answer #2: {d}\n", .{answer_two});
    }
}
