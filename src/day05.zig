const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var lines_list = List([]const u8).init(allocator);
    defer lines_list.deinit();
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        try lines_list.append(trimmed);
    }
    
    // Find blank line
    var index_of_blank: usize = 0;
    for (lines_list.items, 0..) |line, i| {
        if (line.len == 0) {
            index_of_blank = i;
            break;
        }
    }
    
    var ranges = List([2]i64).init(allocator);
    defer ranges.deinit();
    
    var ids = List(i64).init(allocator);
    defer ids.deinit();
    
    // Parse ranges
    for (lines_list.items[0..index_of_blank]) |line| {
        var dash_split = tokenizeSca(u8, line, '-');
        const start = try parseInt(i64, dash_split.next().?, 10);
        const end = try parseInt(i64, dash_split.next().?, 10);
        try ranges.append(.{ start, end });
    }
    
    // Parse IDs
    for (lines_list.items[index_of_blank + 1 ..]) |line| {
        if (line.len > 0) {
            const id = try parseInt(i64, line, 10);
            try ids.append(id);
        }
    }
    
    // Sort ranges
    sort([2]i64, ranges.items, {}, struct {
        fn lessThan(_: void, a: [2]i64, b: [2]i64) bool {
            return a[0] < b[0];
        }
    }.lessThan);
    
    // Part 1
    var fresh_count: usize = 0;
    for (ids.items) |id| {
        for (ranges.items) |range| {
            if (id >= range[0] and id <= range[1]) {
                fresh_count += 1;
                break;
            }
        }
    }
    
    print("{}\n", .{fresh_count});
    
    // Part 2: Merge ranges
    var merged_ranges = List([2]i64).init(allocator);
    defer merged_ranges.deinit();
    
    for (ranges.items) |range| {
        if (merged_ranges.items.len == 0) {
            try merged_ranges.append(range);
            continue;
        }
        
        const last_idx = merged_ranges.items.len - 1;
        const last = merged_ranges.items[last_idx];
        
        // Check if can merge: ranges overlap or are adjacent
        if (!(last[1] < range[0] - 1)) {
            // Merge
            const new_start = @min(last[0], range[0]);
            const new_end = @max(last[1], range[1]);
            merged_ranges.items[last_idx] = .{ new_start, new_end };
        } else {
            try merged_ranges.append(range);
        }
    }
    
    var total_covered: i64 = 0;
    for (merged_ranges.items) |range| {
        total_covered += (range[1] - range[0] + 1);
    }
    
    print("{}\n", .{total_covered});
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
