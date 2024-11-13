const std = @import("std");
const file_name = "input.txt";

pub fn main() !void {
    const dir = std.fs.cwd();
    // std.debug.print("path of cwd: {s}", .{try dir.realpath(".", undefined)});

    const stdin_file = try dir.openFile(file_name, .{});
    defer stdin_file.close();

    var buf_reader = std.io.bufferedReader(stdin_file.reader());
    var stdin = buf_reader.reader();

    var buffer: [1024]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        std.debug.print("{s}\n", .{line});
    }


    { // Solution #1

    }


    { // Solution #2
        
    }
}

// test "simple test" {}
