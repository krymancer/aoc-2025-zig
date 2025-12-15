const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var banks = List([]const u8).init(allocator);
    defer banks.deinit();
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        if (trimmed.len > 0) {
            try banks.append(trimmed);
        }
    }
    
    // Part 1
    var total: i64 = 0;
    for (banks.items) |bank| {
        total += findBestJoltage(bank);
    }
    print("{}\n", .{total});
    
    // Part 2
    total = 0;
    for (banks.items) |bank| {
        total += try findBestJoltage12(allocator, bank);
    }
    print("{}\n", .{total});
}

fn findBestJoltage(bank: []const u8) i64 {
    var max: i64 = -1;
    var i: usize = 0;
    while (i < bank.len - 1) : (i += 1) {
        const di = bank[i] - '0';
        var j = i + 1;
        while (j < bank.len) : (j += 1) {
            const dj = bank[j] - '0';
            const val = @as(i64, di) * 10 + @as(i64, dj);
            if (val > max) max = val;
        }
    }
    return max;
}

fn findBestJoltage12(allocator: Allocator, bank: []const u8) !i64 {
    const k = 12;
    var stack = List(u8).init(allocator);
    defer stack.deinit();
    
    var to_remove = @as(i32, @intCast(bank.len)) - k;
    
    for (bank) |char| {
        const d = char - '0';
        while (stack.items.len > 0 and to_remove > 0) {
            const last = stack.items[stack.items.len - 1] - '0';
            if (last < d) {
                _ = stack.pop();
                to_remove -= 1;
            } else {
                break;
            }
        }
        try stack.append(char);
    }
    
    var result: i64 = 0;
    const slice_len = @min(k, stack.items.len);
    for (stack.items[0..slice_len]) |char| {
        result = result * 10 + @as(i64, char - '0');
    }
    
    return result;
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
