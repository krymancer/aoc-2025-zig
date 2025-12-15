const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");

pub fn main() !void {
    const allocator = gpa;
    
    const Point = struct {
        x: i64,
        y: i64,
        z: i64,
    };
    
    var junction_boxes = List(Point).init(allocator);
    defer junction_boxes.deinit();
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        if (trimmed.len > 0) {
            var coords = tokenizeSca(u8, trimmed, ',');
            const x = try parseInt(i64, coords.next().?, 10);
            const y = try parseInt(i64, coords.next().?, 10);
            const z = try parseInt(i64, coords.next().?, 10);
            try junction_boxes.append(.{ .x = x, .y = y, .z = z });
        }
    }
    
    const n = junction_boxes.items.len;
    
    // Union-Find data structures
    var parent = try allocator.alloc(usize, n);
    defer allocator.free(parent);
    var rank = try allocator.alloc(usize, n);
    defer allocator.free(rank);
    
    for (0..n) |i| {
        parent[i] = i;
        rank[i] = 0;
    }
    
    // Calculate all pairs with distances
    const Pair = struct {
        i: usize,
        j: usize,
        dist: f64,
    };
    
    var all_pairs = List(Pair).init(allocator);
    defer all_pairs.deinit();
    
    for (0..n) |i| {
        for (i + 1..n) |j| {
            const dist = linearDistance(junction_boxes.items[i], junction_boxes.items[j]);
            try all_pairs.append(.{ .i = i, .j = j, .dist = dist });
        }
    }
    
    // Sort pairs by distance
    sort(Pair, all_pairs.items, {}, struct {
        fn lessThan(_: void, a: Pair, b: Pair) bool {
            return a.dist < b.dist;
        }
    }.lessThan);
    
    // Union first 1000 pairs
    for (all_pairs.items[0..@min(1000, all_pairs.items.len)]) |pair| {
        _ = unionSets(parent, rank, pair.i, pair.j);
    }
    
    // Count circuits
    var circuits = Map(usize, List(usize)).init(allocator);
    defer {
        var it = circuits.valueIterator();
        while (it.next()) |list| {
            list.deinit();
        }
        circuits.deinit();
    }
    
    for (0..n) |i| {
        const root = find(parent, i);
        const entry = try circuits.getOrPut(root);
        if (!entry.found_existing) {
            entry.value_ptr.* = List(usize).init(allocator);
        }
        try entry.value_ptr.append(i);
    }
    
    // Get sizes and sort
    var sizes = List(usize).init(allocator);
    defer sizes.deinit();
    
    var it = circuits.valueIterator();
    while (it.next()) |list| {
        try sizes.append(list.items.len);
    }
    
    sort(usize, sizes.items, {}, desc(usize));
    
    var result: i64 = 1;
    for (sizes.items[0..@min(3, sizes.items.len)]) |size| {
        result *= @as(i64, @intCast(size));
    }
    
    print("{}\n", .{result});
    
    // Part 2: Continue unioning until one circuit
    var last_pair: ?Pair = null;
    for (all_pairs.items[@min(1000, all_pairs.items.len)..]) |pair| {
        if (unionSets(parent, rank, pair.i, pair.j)) {
            last_pair = pair;
            if (countCircuits(parent, n) == 1) break;
        }
    }
    
    if (last_pair) |p| {
        const result2 = junction_boxes.items[p.i].x * junction_boxes.items[p.j].x;
        print("{}\n", .{result2});
    }
}

fn linearDistance(a: anytype, b: anytype) f64 {
    const dx = @as(f64, @floatFromInt(a.x - b.x));
    const dy = @as(f64, @floatFromInt(a.y - b.y));
    const dz = @as(f64, @floatFromInt(a.z - b.z));
    return @sqrt(dx * dx + dy * dy + dz * dz);
}

fn find(parent: []usize, x: usize) usize {
    if (parent[x] != x) {
        parent[x] = find(parent, parent[x]);
    }
    return parent[x];
}

fn unionSets(parent: []usize, rank: []usize, x: usize, y: usize) bool {
    const root_x = find(parent, x);
    const root_y = find(parent, y);
    
    if (root_x == root_y) return false;
    
    if (rank[root_x] < rank[root_y]) {
        parent[root_x] = root_y;
    } else if (rank[root_x] > rank[root_y]) {
        parent[root_y] = root_x;
    } else {
        parent[root_y] = root_x;
        rank[root_x] += 1;
    }
    
    return true;
}

fn countCircuits(parent: []const usize, n: usize) usize {
    var roots = Map(usize, void).init(gpa);
    defer roots.deinit();
    
    for (0..n) |i| {
        const root = find(@constCast(parent), i);
        roots.put(root, {}) catch {};
    }
    
    return roots.count();
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
