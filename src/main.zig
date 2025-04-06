const std = @import("std");
const node = @import("node.zig");

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});

    const n = try node.Node.newNode(std.testing.allocator, std.io.getStdIn(), std.io.getStdOut());
    n.initMsg(node.InitMessageBody{ .type = "init", .msg_id = 1, .node_id = "n1", .node_ids = &[_][]const u8{ "n1", "n2", "n3" } });
}
