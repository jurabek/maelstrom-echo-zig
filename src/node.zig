const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

pub const Message = struct {
    src: []const u8,
    dest: []const u8,
    body: Body,
};

pub const Body = struct {
    type: []const u8,
    msg_id: u64,
    in_reply_to: u64,
    echo: []const u8,
};

pub const InitMessageBody = struct {
    type: []const u8,
    msg_id: u64,
    node_id: []const u8,
    node_ids: []const []const u8,
};

pub const InitResponse = struct {
    type: []const u8,
    in_reply_to: u64,
};

pub const Node = struct {
    stdinReader: std.io.Reader,
    stdoutWrite: std.io.Writer,

    pub fn init(_: std.mem.Allocator, stdinReader: std.io.Reader, stdoutWrite: std.io.Writer) !Node {
        return Node{ .stdinReader = stdinReader, .stdoutWrite = stdoutWrite };
    }
};

test "json parse body" {
    const parsed = try std.json.parseFromSlice(
        Body,
        std.testing.allocator,
        \\{ "type": "echo_ok", "msg_id": 1, "in_reply_to": 0, "echo": "hello" }
    ,
        .{},
    );
    defer parsed.deinit();

    const place = parsed.value;

    try expect(eql(u8, place.type, "echo_ok"));
    try expect(place.msg_id == 1);
    try expect(place.in_reply_to == 0);
    try expect(eql(u8, place.echo, "hello"));
}

test "json parse message" {
    const parsed = try std.json.parseFromSlice(
        Message,
        std.testing.allocator,
        \\{ "src": "1", "dest": "2", "body": { "type": "echo_ok", "msg_id": 1, "in_reply_to": 0, "echo": "hello" } }
    ,
        .{},
    );
    defer parsed.deinit();

    const place = parsed.value;

    try expect(eql(u8, place.src, "1"));
    try expect(eql(u8, place.dest, "2"));
    try expect(eql(u8, place.body.type, "echo_ok"));
    try expect(place.body.msg_id == 1);
    try expect(place.body.in_reply_to == 0);
}

test "json parse node and response" {
    const initParsed = try std.json.parseFromSlice(
        InitMessageBody,
        std.testing.allocator,
        \\{ "type": "init", "msg_id": 1, "node_id": "n3", "node_ids": ["n1", "n2", "n3"] }
    ,
        .{},
    );
    defer initParsed.deinit();

    const init = initParsed.value;

    try expect(eql(u8, init.type, "init"));
    try expect(init.msg_id == 1);
    try expect(eql(u8, init.node_id, "n3"));
    try expect(init.node_ids.len == 3);

    const initResponseParsed = try std.json.parseFromSlice(
        InitResponse,
        std.testing.allocator,
        \\{ "type": "init_ok", "in_reply_to": 1 }
    ,
        .{},
    );
    defer initResponseParsed.deinit();

    const initResponse = initResponseParsed.value;

    try expect(eql(u8, initResponse.type, "init_ok"));
    try expect(initResponse.in_reply_to == 1);
}
