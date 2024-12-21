const std = @import("std");
const print = std.debug.print;

const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);

const FILE_LEN = if (testing) 10 else 140;
const FILE_WIDTH = if (testing) 10 else 140;
const TARGET_LENGTH = 4;

const word = "XMAS";
const back_word = "SAMX";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines: [FILE_LEN][FILE_WIDTH]u8 = undefined;
    for (0..FILE_LEN) |i| {
        const line_start = i * (FILE_LEN + 1);
        for (0..FILE_WIDTH) |j| {
            lines[i][j] = file_contents[line_start + j];
        }
    }
    // Collect each item into an array

    // Ensure array was populated properly
    // for (lines) |line| {
    //     std.debug.print("{s}\n", .{line});
    // }

    { // Solution #1
        var word_count: u32 = 0;
        //  Loop through each character horizontally (left->right) and search for xmas or samx

        // std.debug.print("Checking horizontally...\n", .{});
        for (0..FILE_LEN) |row| {
            const vertical_check = row < FILE_LEN - TARGET_LENGTH + 1;
            for (0..FILE_WIDTH) |col| {
                const horizontal_check = col < FILE_WIDTH - TARGET_LENGTH + 1;
                // Horizontal check
                if (horizontal_check) {
                    const is_valid_forwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row][col + offset] != word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid forwards horizontal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    const is_valid_backwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row][col + offset] != back_word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid backwards horizontal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    if (is_valid_forwards or is_valid_backwards) {
                        word_count += 1;
                    }
                }
                // Vertical check
                if (vertical_check) {
                    const is_valid_forwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col] != word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid forwards vertical at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    const is_valid_backwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col] != back_word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid backwards vertical at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    if (is_valid_forwards or is_valid_backwards) {
                        word_count += 1;
                    }
                }
                // Diagonal check down-right
                if (horizontal_check and vertical_check) {
                    const is_valid_forwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col + offset] != word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid forwards diagonal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    const is_valid_backwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col + offset] != back_word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid backwards diagonal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    if (is_valid_forwards or is_valid_backwards) {
                        word_count += 1;
                    }
                }
                // Diagonal check down-left
                if (vertical_check and col >= TARGET_LENGTH - 1) {
                    const is_valid_forwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col - offset] != word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid forwards diagonal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    const is_valid_backwards = blk: {
                        for (0..TARGET_LENGTH) |offset| {
                            if (lines[row + offset][col - offset] != back_word[offset]) {
                                break :blk false;
                            }
                        }
                        // print("Found valid backwards diagonal at {d}, {d}\n", .{ row, col });
                        break :blk true;
                    };
                    if (is_valid_forwards or is_valid_backwards) {
                        word_count += 1;
                    }
                }
            }
        }

        std.debug.print("Answer #1: {d}\n", .{word_count});
    }

    { // Solution #2
        var crosses: u32 = 0;
        var found = std.ArrayList(u8).init(allocator);
        defer found.deinit();
        for (1..FILE_LEN - 1) |i| {
            for (1..FILE_WIDTH - 1) |j| {
                if (lines[i][j] == 'A') {
                    const surrounding = [4]u8{
                        lines[i - 1][j - 1],
                        lines[i - 1][j + 1],
                        lines[i + 1][j + 1],
                        lines[i + 1][j - 1],
                    };
                    // std.debug.print("Found potential cross at {d} , {d} -> {s}\n", .{ i, j, surrounding });
                    if (std.mem.count(u8, "MSSM SSMM SMMS MMSS", &surrounding) > 0) {
                        // std.debug.print("Found cross!!\n", .{});
                        crosses += 1;
                    }
                }
            }
        }
        std.debug.print("Answer #2: {d}\n", .{crosses});
    }
}

fn count_occurances(list: *std.ArrayList(u8)) u32 {
    const word_count = std.mem.count(u8, list.items, word);
    const bword_count = std.mem.count(u8, list.items, back_word);
    if (word_count > 0 or bword_count > 0) {
        // std.debug.print("Found word {d} times and backwards word {d} times!\n", .{ word_count, bword_count });
    }
    return @as(u32, @intCast(word_count + bword_count));
}

fn count_iter(multi_iterator: anytype, list: *std.ArrayList(u8), new_row: usize, new_col: usize) !u32 {
    multi_iterator.resetStart(new_row, new_col);
    while (multi_iterator.next()) |char| {
        // std.debug.print("Collected: {c}", .{char});
        try list.append(char);
    }
    // std.debug.print("Window: {s}\n", .{list.items});
    const count = count_occurances(list);
    list.clearRetainingCapacity();
    return count;
}

//// This was funny but ultimately not worth it...
// fn Iterator2D(comptime T: type, comptime length: usize, comptime width: usize) type {
//     return struct {
//         grid: [length][width]T,
//         curr_row: usize,
//         curr_col: usize,
//         advance_row: i8,
//         advance_col: i8,
//         ended: bool,
//         const Self = @This();
//
//         pub fn init(grid: [length][width]T, start_row: usize, start_col: usize, row_change: i8, col_change: i8) !Self {
//             if (row_change == 0 and col_change == 0) {
//                 return error.InfiniteIterator;
//             }
//             return Self{
//                 .grid = grid,
//                 .curr_row = start_row,
//                 .curr_col = start_col,
//                 .advance_row = row_change,
//                 .advance_col = col_change,
//                 .ended = false,
//             };
//         }
//
//         pub fn next(self: *Self) ?T {
//             if (self.ended) {
//                 return null;
//             }
//             const current_val = self.grid[self.curr_row][self.curr_col];
//
//             const next_row = @as(isize, @intCast(self.curr_row)) + self.advance_row;
//             const next_col = @as(isize, @intCast(self.curr_col)) + self.advance_col;
//
//             if (next_row < 0 or next_row >= length or next_col < 0 or next_col >= width) {
//                 self.ended = true;
//             } else {
//                 self.curr_row = @as(usize, @intCast(next_row));
//                 self.curr_col = @as(usize, @intCast(next_col));
//             }
//             return current_val;
//         }
//         pub fn resetStart(self: *Self, new_start_row: usize, new_start_col: usize) void {
//             self.ended = false;
//             self.curr_row = new_start_row;
//             self.curr_col = new_start_col;
//         }
//         pub fn changeAdvance(self: *Self, new_advance_row: i8, new_advance_col: i8) void {
//             self.ended = false;
//             self.advance_row = new_advance_row;
//             self.advance_col = new_advance_col;
//         }
//     };
// }
