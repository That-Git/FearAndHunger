const std = @import("std");
const mem = std.mem;
const os = std.posix.system;
const stdout = std.io.getStdOut().writer();

const spoon = @import("spoon");

var term: spoon.Term = undefined;
var loop: bool = true;

var cursor: usize = 0;

fn argue() ?bool {
    const a: [][*:0]u8 = std.os.argv;
    var face: []const u8 = "";
    for (a[1..a.len]) |arg| {
        face = mem.span(arg);
        if (mem.eql(u8, face, "heads")) {
            return true;
        } else if (mem.eql(u8, face, "tails")) {
            return false;
        }
    }
    return null;
}

pub fn main() void {
    const arg = argue();
    if (arg == null) {
        select() catch {};
        term.deinit() catch {};
        print(0 == cursor % 2);
    } else {
        print(arg orelse unreachable);
    }
}

fn print(face: bool) void {
    const win = std.crypto.random.boolean();
    if (face) {
        stdout.print("heads", .{}) catch {};
    } else {
        stdout.print("tails", .{}) catch {};
    }
    if (win) {
        stdout.print(" won!", .{}) catch {};
    } else {
        stdout.print(" lost!", .{}) catch {};
    }
}

fn select() !void {
    try term.init(.{});
    defer term.deinit() catch {};

    std.posix.sigaction(os.SIG.WINCH, &os.Sigaction{
        .handler = .{ .handler = handleSigWinch },
        .mask = os.empty_sigset,
        .flags = 0,
    }, null);

    var fds: [1]os.pollfd = undefined;
    fds[0] = .{
        .fd = term.tty.?,
        .events = os.POLL.IN,
        .revents = undefined,
    };

    // zig-spoon will return the terminal back to cooked state automatically
    // when we call term.deinit().
    try term.uncook(.{});

    try term.fetchSize();
    try term.setWindowTitle("feeling luck punk?", .{});
    try render();

    var buf: [16]u8 = undefined;
    while (loop) {
        _ = try std.posix.poll(&fds, -1);

        const read = try term.readInput(&buf);
        var it = spoon.inputParser(buf[0..read]);
        while (it.next()) |in| {
            // The input descriptor parser is not only useful for user-configuration.
            // Since it can work at comptime, you can use it to simplify the
            // matching of hardcoded keybinds as well. Down below we specify the
            // typical keybinds a terminal user would expect for moving up and
            // down, without getting our hands dirty in the interals of zig-spoons
            // Input object.
            if (in.eqlDescription("escape") or in.eqlDescription("q") or in.eqlDescription("enter")) {
                loop = false;
                if (!in.eqlDescription("enter")) {
                    term.deinit() catch {};
                    std.process.exit(0);
                }
                break;
            } else if (in.eqlDescription("arrow-down") or in.eqlDescription("C-n") or in.eqlDescription("j")) {
                if (cursor < 1) {
                    cursor += 1;
                } else {
                    cursor -= 1;
                }
                try render();
            } else if (in.eqlDescription("arrow-up") or in.eqlDescription("C-p") or in.eqlDescription("k")) {
                if (cursor < 1) {
                    cursor += 1;
                } else {
                    cursor -|= 1;
                }
                try render();
            }
        }
    }
}

fn render() !void {
    var rc = try term.getRenderContext();
    defer rc.done() catch {};

    try rc.clear();

    if (term.width < 6) {
        try rc.setAttribute(.{ .fg = .red, .bold = true });
        try rc.writeAllWrapping("Terminal too small!");
        return;
    }

    try rc.moveCursorTo(0, 0);
    try rc.setAttribute(.{ .fg = .green, .reverse = true });

    // The RestrictedPaddingWriter helps us avoid writing more than the terminal
    // is wide. It exposes a normal writer interface you can use with any
    // function that integrates with that, such as print(), write() and writeAll().
    // The RestrictedPaddingWriter.pad() function will fill the remaining space
    // with whitespace padding.
    var rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll(" feeling lucky punk?");
    try rpw.pad();

    try rc.moveCursorTo(1, 0);
    try rc.setAttribute(.{ .fg = .red, .bold = true });
    rpw = rc.restrictedPaddingWriter(term.width);
    try rpw.writer().writeAll(" flipping coins");
    try rpw.finish(); // No need to pad here, since there is no background.

    const entry_width = @min(term.width - 2, 8);
    try menuEntry(&rc, " heads", 3, entry_width);
    try menuEntry(&rc, " tails", 4, entry_width);
    // try menuEntry(&rc, " →µ←", 6, entry_width);
}

fn menuEntry(rc: *spoon.Term.RenderContext, name: []const u8, row: usize, width: usize) !void {
    try rc.moveCursorTo(row, 2);
    try rc.setAttribute(.{ .fg = .blue, .reverse = (cursor == row - 3) });
    var rpw = rc.restrictedPaddingWriter(width - 1);
    defer rpw.pad() catch {};
    try rpw.writer().writeAll(name);
}

fn handleSigWinch(_: c_int) callconv(.C) void {
    term.fetchSize() catch {};
    render() catch {};
}
