const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var graph = StrMap(List([]const u8)).init(allocator);
    defer {
        var it = graph.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        graph.deinit();
    }
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        
        const colon_idx = indexOf(u8, trimmed, ':') orelse continue;
        const device = trimmed[0..colon_idx];
        const outputs_str = trim(u8, trimmed[colon_idx + 1 ..], " ");
        
        const entry = try graph.getOrPut(device);
        if (!entry.found_existing) {
            entry.value_ptr.* = List([]const u8).init(allocator);
        }
        
        var outputs = tokenizeSca(u8, outputs_str, ' ');
        while (outputs.next()) |output| {
            try entry.value_ptr.append(output);
        }
    }
    
    var cache = StrMap(i64).init(allocator);
    defer cache.deinit();
    
    // Part 1
    const result1 = try countPaths(allocator, &graph, &cache, "you", "out");
    print("{}\n", .{result1});
    
    // Part 2
    const start_to_dac = try countPaths(allocator, &graph, &cache, "svr", "dac");
    const start_to_fft = try countPaths(allocator, &graph, &cache, "svr", "fft");
    const dac_to_fft = try countPaths(allocator, &graph, &cache, "dac", "fft");
    const fft_to_dac = try countPaths(allocator, &graph, &cache, "fft", "dac");
    const fft_to_out = try countPaths(allocator, &graph, &cache, "fft", "out");
    const dac_to_out = try countPaths(allocator, &graph, &cache, "dac", "out");
    
    const part2 = start_to_dac * dac_to_fft * fft_to_out + start_to_fft * fft_to_dac * dac_to_out;
    print("{}\n", .{part2});
}

fn countPaths(
    allocator: Allocator,
    graph: *const StrMap(List([]const u8)),
    cache: *StrMap(i64),
    start: []const u8,
    end: []const u8,
) !i64 {
    // Create cache key
    const key = try std.fmt.allocPrint(allocator, "{s},{s}", .{ start, end });
    defer allocator.free(key);
    
    if (cache.get(key)) |cached| {
        return cached;
    }
    
    var paths: i64 = 0;
    
    if (graph.get(start)) |neighbors| {
        for (neighbors.items) |neighbor| {
            if (std.mem.eql(u8, neighbor, end)) {
                paths += 1;
            } else if (graph.contains(neighbor)) {
                paths += try countPaths(allocator, graph, cache, neighbor, end);
            }
        }
    }
    
    // Store in cache (need to allocate key)
    const cache_key = try allocator.dupe(u8, key);
    try cache.put(cache_key, paths);
    
    return paths;
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
