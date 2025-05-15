const std = @import("std");
const lib = @import("FearAndHunger_lib");
const mem = std.mem;

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
        print(0 == lib.position() catch {} % 2);
    } else {
        print(arg.?);
    }
}

fn print(face: bool) void {
    const stdout = std.io.getStdOut().writer();
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
