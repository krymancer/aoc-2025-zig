const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var lines_list = List([]const u8).init(allocator);
    defer lines_list.deinit();
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        if (trimmed.len > 0) {
            try lines_list.append(trimmed);
        }
    }
    
    if (lines_list.items.len == 0) return;
    
    const rows = lines_list.items.len;
    const cols = lines_list.items[0].len;
    
    // Find start position
    var start: usize = 0;
    for (lines_list.items[0], 0..) |c, i| {
        if (c == 'S') {
            start = i;
            break;
        }
    }
    
    // Part 1
    var beams = Map(usize, void).init(allocator);
    defer beams.deinit();
    try beams.put(start, {});
    
    var splits: usize = 0;
    
    var row: usize = 1;
    while (row < rows) : (row += 1) {
        var next_beams = Map(usize, void).init(allocator);
        defer {
            var it = beams.keyIterator();
            while (it.next()) |_| {}
            beams.deinit();
        }
        
        var it = beams.keyIterator();
        while (it.next()) |col_ptr| {
            const col = col_ptr.*;
            if (col >= cols) continue;
            
            if (lines_list.items[row][col] == '^') {
                splits += 1;
                if (col > 0) {
                    try next_beams.put(col - 1, {});
                }
                if (col + 1 < cols) {
                    try next_beams.put(col + 1, {});
                }
            } else {
                try next_beams.put(col, {});
            }
        }
        
        beams = next_beams;
    }
    
    print("{}\n", .{splits});
    
    // Part 2: Count timelines
    var active_columns = Map(usize, usize).init(allocator);
    defer active_columns.deinit();
    try active_columns.put(start, 1);
    
    var timeline_count: usize = 1;
    
    row = 1;
    while (row < rows) : (row += 1) {
        var next_columns = Map(usize, usize).init(allocator);
        defer {
            active_columns.deinit();
        }
        
        var it = active_columns.iterator();
        while (it.next()) |entry| {
            const col = entry.key_ptr.*;
            const count = entry.value_ptr.*;
            
            if (col >= cols) continue;
            
            if (lines_list.items[row][col] == '^') {
                if (col > 0) {
                    const left_col = col - 1;
                    const current = next_columns.get(left_col) orelse 0;
                    try next_columns.put(left_col, current + count);
                }
                if (col + 1 < cols) {
                    const right_col = col + 1;
                    const current = next_columns.get(right_col) orelse 0;
                    try next_columns.put(right_col, current + count);
                }
                timeline_count += count;
            } else {
                const current = next_columns.get(col) orelse 0;
                try next_columns.put(col, current + count);
            }
        }
        
        active_columns = next_columns;
    }
    
    print("{}\n", .{timeline_count});
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
