const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");

pub fn main() !void {
    const allocator = gpa;
    
    const trimmed_data = trim(u8, data, " \n\r\t");
    
    // Split by double newline
    var sections = splitSeq(u8, trimmed_data, "\n\n");
    _ = sections.next(); // Skip first sections (if any)
    
    // Get trees section
    var trees_section: []const u8 = "";
    while (sections.next()) |section| {
        trees_section = section;
    }
    
    const Tree = struct {
        w: i64,
        h: i64,
        presents: List(i64),
    };
    
    var trees = List(Tree).init(allocator);
    defer {
        for (trees.items) |tree| {
            tree.presents.deinit();
        }
        trees.deinit();
    }
    
    var lines = tokenizeSca(u8, trees_section, '\n');
    while (lines.next()) |line| {
        const colon_idx = indexOf(u8, line, ':') orelse continue;
        const area_str = trim(u8, line[0..colon_idx], " ");
        const presents_str = trim(u8, line[colon_idx + 1 ..], " ");
        
        // Parse area
        const x_idx = indexOf(u8, area_str, 'x') orelse continue;
        const w = try parseInt(i64, area_str[0..x_idx], 10);
        const h = try parseInt(i64, area_str[x_idx + 1 ..], 10);
        
        // Parse presents
        var presents = List(i64).init(allocator);
        var present_tokens = tokenizeSca(u8, presents_str, ' ');
        while (present_tokens.next()) |token| {
            const num = try parseInt(i64, token, 10);
            try presents.append(num);
        }
        
        try trees.append(.{ .w = w, .h = h, .presents = presents });
    }
    
    // Part 1: Count valid trees
    var valid: i64 = 0;
    
    for (trees.items) |tree| {
        const area = tree.w * tree.h;
        
        var shapes: i64 = 0;
        for (tree.presents.items) |present| {
            shapes += present;
        }
        
        if (area >= 9 * shapes) {
            valid += 1;
        }
    }
    
    print("{}\n", .{valid});
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
