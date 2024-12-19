const std = @import("std");
const print = std.debug.print;
const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);
const FILE_LEN = if (testing) 10 else 130;
const FILE_WIDTH = if (testing) 10 else 130;
var START_POS: Vec2(isize) = undefined;

const word = "XMAS";
const back_word = "SAMX";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    _ = allocator;

    var grid: [FILE_LEN][FILE_WIDTH]u8 = undefined;
    for (0..FILE_LEN) |i| {
        const line_start = i * (FILE_LEN + 1);
        for (0..FILE_WIDTH) |j| {
            const curr = file_contents[line_start + j];
            if (curr == '^') {
                START_POS = Vec2(isize){
                    .x = @as(isize, @intCast(i)),
                    .y = @as(isize, @intCast(j)),
                };
            }
            grid[i][j] = curr;
        }
    }

    { // Print Input
        // if (testing) {
        //     print("Test input: \n", .{});
        //     for (file_contents) |char| {
        //         print("{c}", .{char});
        //     }
        // }
    }
    { // Solution #1
        var answer: u32 = 0;

        var traveler_pos = Vec2(isize).from(START_POS);
        var dir = Vec2(isize){
            .x = -1,
            .y = 0,
        };
        while (true) {
            const new_pos = traveler_pos.sum(dir);
            // Check if new pos out of bounds
            // print("Visiting position: {d},{d}\n", .{ new_pos.x, new_pos.y });
            if (new_pos.x < 0 or new_pos.x >= grid.len or new_pos.y < 0 or new_pos.y >= grid[0].len) {
                // Reached an edge
                break;
            }
            const grid_x = @as(usize, @intCast(new_pos.x));
            const grid_y = @as(usize, @intCast(new_pos.y));
            const grid_val = grid[grid_x][grid_y];
            if (grid_val == '#') {
                // Rotate moving direction
                if (dir.y < 0) { // 0,-1
                    dir.x = -1;
                    dir.y = 0;
                } else if (dir.y > 0) { // 0,1
                    dir.x = 1;
                    dir.y = 0;
                } else if (dir.x < 0) { // -1,0
                    dir.x = 0;
                    dir.y = 1;
                } else if (dir.x > 0) { // 1,0
                    dir.x = 0;
                    dir.y = -1;
                }
                // print("Rotated dir to: {d},{d}\n", .{ dir.x, dir.y });
            } else if (grid_val == 'X') {
                traveler_pos.copy(new_pos);
            } else {
                answer += 1;
                grid[grid_x][grid_y] = 'X';
                traveler_pos.copy(new_pos);
            }
        }

        print("Answer #1: {d}\n", .{answer});
        print("Final position was: {d},{d}\n", .{ traveler_pos.x, traveler_pos.y });
    }

    { // Solution #2

        var answer: u32 = 0;
        answer += 1;

        print("Answer #2: {d}\n", .{answer});
    }
}

fn printList(list: *const std.ArrayList([]const u8)) void {
    print("{{", .{});
    for (list.items) |item| {
        print("{s},", .{item});
    }
    print("}}\n", .{});
}

fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        const Self = @This();
        fn from(other: Self) Self {
            return Self{
                .x = other.x,
                .y = other.y,
            };
        }
        fn sum(self: Self, other: Self) Self {
            return Self{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }
        fn copy(self: *Self, other: Self) void {
            self.x = other.x;
            self.y = other.y;
        }
    };
}
