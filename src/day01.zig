const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    // Part 1
    var lines = tokenizeSca(u8, data, '\n');
    var dial: i32 = 50;
    var password: i32 = 0;
    
    while (lines.next()) |line| {
        const direction: i32 = if (line[0] == 'L') -1 else 1;
        const rotation = try parseInt(i32, line[1..], 10);
        
        const value = rotate(dial, rotation, direction);
        
        if (value == 0) password += 1;
        dial = value;
    }
    
    print("{}\n", .{password});
    
    // Part 2
    lines = tokenizeSca(u8, data, '\n');
    dial = 50;
    password = 0;
    
    while (lines.next()) |line| {
        const rotation = try parseInt(i32, line[1..], 10);
        const direction: i32 = if (line[0] == 'L') -1 else 1;
        
        var clicks: i32 = undefined;
        if (dial == 0) {
            clicks = 100;
        } else if (direction == 1) {
            clicks = 100 - dial;
        } else {
            clicks = dial;
        }
        
        var passes: i32 = 0;
        
        if (rotation >= clicks) {
            passes = 1;
            const remaining = rotation - clicks;
            passes += @divFloor(remaining, 100);
        }
        
        password += passes;
        dial = rotate(dial, rotation, direction);
    }
    
    print("{}\n", .{password});
}

fn rotate(value: i32, rotation: i32, direction: i32) i32 {
    const raw = value + (rotation * direction);
    return @mod(@mod(raw, 100) + 100, 100);
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
