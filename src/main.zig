const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

const Message = struct {
    src: u64,
    dest: u64,
    body: Body,
};

const Body = struct {
    type: []const u8,
    msg_id: u64,
    in_reply_to: u64,
    echo: []const u8,
};

pub fn main() !void {
    std.debug.print("Hello, world!\n", .{});
}

test "json parse" {
    const parsed = try std.json.parseFromSlice(
        Body,
        std.test_allocator,
        \\{ "type": "echo", "msg_id": 1, "in_reply_to": 0, "echo": "hello" }
    ,
        .{},
    );
    defer parsed.deinit();

    const place = parsed.value;

    try expect(eql(u8, place.type, "echo"));
    try expect(place.msg_id == 1);
    try expect(place.in_reply_to == 0);
    try expect(eql(u8, place.echo, "hello"));
}
