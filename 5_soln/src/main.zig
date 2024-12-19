const std = @import("std");
const print = std.debug.print;
const testing = false;
const file_name = if (testing) "test_input.txt" else "input.txt";
const file_contents = @embedFile(file_name);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var substring_list = std.ArrayList([]const u8).init(allocator);
    defer substring_list.deinit();

    var split = std.mem.tokenizeSequence(u8, file_contents, "\n\n");
    var rules = std.mem.splitAny(u8, (split.next() orelse unreachable), "\n");
    var updates = std.mem.splitAny(u8, (split.next() orelse unreachable), "\n");

    // Collect rules into hashmap, where key is the left hand side and val is a set of all numbers which must come after key
    var rule_map = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);
    defer {
        var iter = rule_map.valueIterator();
        while (iter.next()) |list| {
            list.deinit();
        }
        rule_map.deinit();
    }

    // Populate hash map with sets of rules for each key
    while (rules.next()) |rule| {
        var rule_vals = std.mem.splitAny(u8, rule, "|");
        const left = rule_vals.next().?;
        const right = rule_vals.next().?;
        // print("LEFT: {s} RIGHT {s}\n", .{ left, right });
        var entry = try rule_map.getOrPut(left);
        if (!entry.found_existing) {
            // print("Didn't contain {s}, adding it to the map! \n", .{left});
            const list = entry.value_ptr;
            list.* = std.ArrayList([]const u8).init(allocator);
            try list.append(right);
            // printList(list);
        } else {
            // print("Did contain {s}, adding it to the list at {s} \n", .{ left, left });
            try entry.value_ptr.append(right);
            // printList(entry.value_ptr);
        }
    }

    // After finding each invalid update, store it in a list for problem #2
    var invalid_updates = std.ArrayList([]const u8).init(allocator);
    defer invalid_updates.deinit();

    // var iter = rule_map.valueIterator();
    // while (iter.next()) |elem| {
    //     printList(elem);
    // }
    // Iterate through each update
    // Check if each element has an index in the update greater than any element they are mapped to
    var valid_middle_sum: u32 = 0;
    while (updates.next()) |update| {
        if (update.len < 1) {
            continue;
        }
        var update_vals = std.mem.splitAny(u8, update, ",");
        var update_list = std.ArrayList([]const u8).init(allocator);
        defer update_list.deinit();

        // Collect updates into slice
        while (update_vals.next()) |key| {
            // print("Collecing into update list {s}...\n", .{key});
            if (key.len > 0) {
                try update_list.append(key);
            }
        }

        var valid = true;
        for (update_list.items, 0..) |key, i| {
            if (i == 0) {
                continue;
            }
            // Check if this value comes
            const next_list = rule_map.get(key) orelse continue;
            const key_pos = std.mem.indexOf(u8, update, key).?;
            for (next_list.items) |val| {
                const val_pos = std.mem.indexOf(u8, update, val) orelse continue;
                if (key_pos > val_pos) {
                    valid = false;
                    break;
                }
            }
        }

        if (valid) {
            const middle_index = @divTrunc(update_list.items.len, 2);
            const middle_str = update_list.items[middle_index];
            const middle_val = std.fmt.parseInt(u32, middle_str, 10) catch |err| switch (err) {
                error.Overflow => {
                    // print("Middle value ({s}) too large and overflowed\n", .{middle_str});
                    continue;
                },
                error.InvalidCharacter => {
                    // print("Middle value ({s}) not parsed correctly\n", .{middle_str});
                    continue;
                },
            };
            valid_middle_sum += middle_val;
        } else {
            try invalid_updates.append(update);
        }
    }
    print("Answer #1: {d}\n", .{valid_middle_sum});
    // Problem #2:
    var invalid_middle_sum: u32 = 0;
    // print("Invalid updates... \n", .{});
    for (invalid_updates.items) |list| {
        var invalid_iter = std.mem.splitAny(u8, list, ",");
        var invalid_buffer = std.ArrayList([]const u8).init(allocator);
        defer invalid_buffer.deinit();
        while (invalid_iter.next()) |update| {
            try invalid_buffer.append(update);
        }
        const invalid_items = try invalid_buffer.toOwnedSlice();
        defer allocator.free(invalid_items);
        std.mem.sort([]const u8, invalid_items, MapWrapper{ .rule_map = rule_map }, updateLessThan);
        const middle_index = @divTrunc(invalid_items.len, 2);
        const middle_str = invalid_items[middle_index];
        const middle_val = std.fmt.parseInt(u32, middle_str, 10) catch |err| switch (err) {
            error.Overflow => {
                // print("Middle value ({s}) too large and overflowed\n", .{middle_str});
                continue;
            },
            error.InvalidCharacter => {
                // print("Middle value ({s}) not parsed correctly\n", .{middle_str});
                continue;
            },
        };
        invalid_middle_sum += middle_val;
    }
    print("Answer #2: {d}\n", .{invalid_middle_sum});
}

fn printList(list: *const std.ArrayList([]const u8)) void {
    print("{{", .{});
    for (list.items) |item| {
        print("{s},", .{item});
    }
    print("}}\n", .{});
}
const MapWrapper = struct {
    rule_map: std.StringHashMap(std.ArrayList([]const u8)),
};

fn updateLessThan(ctx: MapWrapper, lhs: []const u8, rhs: []const u8) bool {
    const rule_map = ctx.rule_map;

    const next_list = rule_map.get(lhs) orelse return false;
    for (next_list.items) |val| {
        if (std.mem.eql(u8, val, rhs)) {
            return true;
        }
    }
    return false;
}
