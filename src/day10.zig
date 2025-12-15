const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

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
    
    // Part 1: Brute force GF(2) solution
    var total_presses: i64 = 0;
    
    for (lines_list.items) |line| {
        const result = try parseLine(allocator, line);
        defer {
            result.lights.deinit();
            for (result.buttons.items) |btn| {
                btn.deinit();
            }
            result.buttons.deinit();
            result.joltages.deinit();
        }
        
        const presses = try solveGaussianGF2(allocator, result.lights.items, result.buttons.items);
        total_presses += presses;
    }
    
    print("{}\n", .{total_presses});
    
    // Part 2: More complex Gaussian with joltages
    print("Part 2 requires complex Gaussian elimination - see JavaScript version\n", .{});
}

const ParseResult = struct {
    lights: List(u8),
    buttons: List(List(usize)),
    joltages: List(i64),
};

fn parseLine(allocator: Allocator, line: []const u8) !ParseResult {
    var lights = List(u8).init(allocator);
    var buttons = List(List(usize)).init(allocator);
    var joltages = List(i64).init(allocator);
    
    // Parse lights: [.#.#]
    const lights_start = indexOf(u8, line, '[').? + 1;
    const lights_end = indexOf(u8, line[lights_start..], ']').? + lights_start;
    
    for (line[lights_start..lights_end]) |c| {
        try lights.append(if (c == '#') 1 else 0);
    }
    
    // Parse buttons: (1,2,3)(4,5)
    var i = lights_end + 1;
    while (i < line.len) {
        if (line[i] == '(') {
            const start = i + 1;
            const end = indexOf(u8, line[start..], ')').? + start;
            
            var btn = List(usize).init(allocator);
            var nums = tokenizeSca(u8, line[start..end], ',');
            while (nums.next()) |num_str| {
                const num = try parseInt(usize, num_str, 10);
                try btn.append(num);
            }
            try buttons.append(btn);
            
            i = end + 1;
        } else if (line[i] == '{') {
            // Parse joltages: {1,2,3}
            const start = i + 1;
            const end = indexOf(u8, line[start..], '}').? + start;
            
            var nums = tokenizeSca(u8, line[start..end], ',');
            while (nums.next()) |num_str| {
                const num = try parseInt(i64, num_str, 10);
                try joltages.append(num);
            }
            break;
        } else {
            i += 1;
        }
    }
    
    return ParseResult{
        .lights = lights,
        .buttons = buttons,
        .joltages = joltages,
    };
}

fn solveGaussianGF2(allocator: Allocator, target: []const u8, buttons: []const List(usize)) !i64 {
    const n = target.len;
    const m = buttons.len;
    
    var min_presses: i64 = std.math.maxInt(i64);
    
    const max_mask = @as(usize, 1) << @intCast(m);
    var mask: usize = 0;
    while (mask < max_mask) : (mask += 1) {
        var state = try allocator.alloc(u8, n);
        defer allocator.free(state);
        @memset(state, 0);
        
        var presses: i64 = 0;
        
        for (0..m) |j| {
            if ((mask & (@as(usize, 1) << @intCast(j))) != 0) {
                presses += 1;
                for (buttons[j].items) |light| {
                    state[light] ^= 1;
                }
            }
        }
        
        var valid = true;
        for (0..n) |i| {
            if (state[i] != target[i]) {
                valid = false;
                break;
            }
        }
        
        if (valid and presses < min_presses) {
            min_presses = presses;
        }
    }
    
    return if (min_presses == std.math.maxInt(i64)) 0 else min_presses;
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
