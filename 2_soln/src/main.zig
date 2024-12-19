const std = @import("std");

const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const input_size = 1000;
const file_content = @embedFile(file_name);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var reports = std.ArrayList([]u32).init(allocator);
    defer { // Free each nested list and free the arraylist
        for (reports.items) |item| {
            allocator.free(item);
        }
        reports.deinit();
    }

    var lines = std.mem.tokenizeAny(u8, file_content, "\n");
    while (lines.next()) |line| {
        if (reports.items.len >= input_size) {
            break;
        }
        var value_list = std.ArrayList(u32).init(allocator);
        defer value_list.deinit();

        var value_iterator = std.mem.tokenizeAny(u8, line, " ");
        while (value_iterator.next()) |value| {
            const val = try std.fmt.parseInt(u32, value, 10);
            try value_list.append(val);
        }
        const owned = try value_list.toOwnedSlice();
        try reports.append(owned);
    }

    { // Solution #1
        var sum: u32 = 0;
        for (reports.items, 0..) |report, i| {
            // printRow(i, &report);
            _ = i;

            const isValid = validateRow1(report);

            if (isValid) {
                // std.debug.print("VALID!\n", .{});
                sum += 1;
            }
        }
        std.debug.print("Answer #1: {d}\n", .{sum});
    }

    { // Solution #2
        var sum: u32 = 0;
        for (reports.items, 0..) |report, i| {
            _ = i;
            // printRow(i, &report);

            const is_valid = try validateRow2(allocator, report);
            if (is_valid) {
                // std.debug.print("VALID!\n", .{});
                sum += 1;
            }
        }
        std.debug.print("Answer #2: {d}\n", .{sum});
    }
}

fn printRow(i: usize, list: *const []u32) void {
    std.debug.print("{d}: ", .{i});
    for (list.*) |item| {
        std.debug.print("{d} ", .{item});
    }
    std.debug.print("\n", .{});
}

fn validateRow1(report: []u32) bool {
    const increasing = report[0] < report[1];
    for (0..report.len - 1) |i| {
        const l = report[i];
        const r = report[i + 1];
        const diff = std.math.sub(u32, l, r) catch |err| switch (err) {
            error.Overflow => r - l,
        };
        if (diff > 3 or diff == 0) {
            // std.debug.print("INVALID: Diff too great or neutral\n", .{});
            return false;
        }
        if (l < r and !increasing) {
            // std.debug.print("INVALID: Decreasing to increasing\n", .{});
            return false;
        } else if (l > r and increasing) {
            // std.debug.print("INVALID: Increasing to Decreasing\n", .{});
            return false;
        }
    }
    return true;
}

fn validateRow2(allocator: std.mem.Allocator, report: []u32) !bool {
    const increasing = report[0] < report[1];
    for (0..report.len - 1) |i| {
        const l = report[i];
        const r = report[i + 1];
        const diff = std.math.sub(u32, l, r) catch |err| switch (err) {
            error.Overflow => r - l,
        };
        if (diff > 3 or diff == 0) {
            // std.debug.print("INVALID: Diff too great or neutral\n", .{});
            // std.debug.print("   Double checking...\n", .{});
            return try doubleCheck(allocator, report, i);
        }
        if (l < r and !increasing) {
            // std.debug.print("INVALID: Decreasing to increasing\n", .{});
            // std.debug.print("   Double checking...\n", .{});
            return try doubleCheck(allocator, report, i);
        } else if (l > r and increasing) {
            // std.debug.print("INVALID: Increasing to decreasing!\n", .{});
            // std.debug.print("   Double checking...\n", .{});
            return try doubleCheck(allocator, report, i);
        }
    }
    return true;
}

fn doubleCheck(allocator: std.mem.Allocator, report: []u32, idx: usize) !bool {
    if (idx > 0) {
        const prev_removed = try getSliceExcept(allocator, report, idx - 1);
        defer allocator.free(prev_removed);
        if (validateRow1(prev_removed)) {
            return true;
        }
    }
    const curr_removed = try getSliceExcept(allocator, report, idx);
    defer allocator.free(curr_removed);
    if (validateRow1(curr_removed)) {
        return true;
    }
    const next_removed = try getSliceExcept(allocator, report, idx + 1);
    defer allocator.free(next_removed);

    if (validateRow1(next_removed)) {
        return true;
    }

    return false;
}

fn getSliceExcept(allocator: std.mem.Allocator, values: []u32, except_idx: usize) ![]u32 {
    if (except_idx > values.len) {
        return error.IndexOutOfBounds;
    }
    const new_slice = try allocator.alloc(u32, values.len - 1);
    errdefer allocator.free(new_slice);
    for (0..except_idx) |i| {
        new_slice[i] = values[i];
    }
    for (except_idx..values.len - 1) |i| {
        new_slice[i] = values[i + 1];
    }

    // std.debug.print("NEW ROW EXCEPT ", .{});
    // printRow(except_idx, &new_slice);

    return new_slice;
}
