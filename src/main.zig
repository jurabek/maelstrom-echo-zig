const std = @import("std");
const node = @import("node.zig");

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});

    const n = try node.Node.init(std.testing.allocator, std.io.getStdIn(), std.io.getStdOut());

    _ = n;
}
