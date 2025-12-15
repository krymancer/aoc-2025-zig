const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var grid = List(List(u8)).init(allocator);
    defer {
        for (grid.items) |row| {
            row.deinit();
        }
        grid.deinit();
    }
    
    var lines = tokenizeSca(u8, data, '\n');
    while (lines.next()) |line| {
        const trimmed = trim(u8, line, " \t\r");
        if (trimmed.len > 0) {
            var row = List(u8).init(allocator);
            for (trimmed) |c| {
                try row.append(c);
            }
            try grid.append(row);
        }
    }
    
    // Part 1
    var all_neighbors = List(struct { x: usize, y: usize, count: usize }).init(allocator);
    defer all_neighbors.deinit();
    
    for (grid.items, 0..) |row, i| {
        for (row.items, 0..) |cell, j| {
            if (cell != '@') continue;
            const count = countNeighbors(&grid, i, j);
            try all_neighbors.append(.{ .x = i, .y = j, .count = count });
        }
    }
    
    var forklift_accessible: usize = 0;
    for (all_neighbors.items) |cell| {
        if (cell.count < 4) forklift_accessible += 1;
    }
    
    print("{}\n", .{forklift_accessible});
    
    // Part 2
    var iterations: usize = 0;
    var total_removed: usize = 0;
    
    while (true) {
        all_neighbors.clearRetainingCapacity();
        removeMarked(&grid, 'x');
        
        for (grid.items, 0..) |row, i| {
            for (row.items, 0..) |cell, j| {
                if (cell != '@') continue;
                const count = countNeighbors(&grid, i, j);
                try all_neighbors.append(.{ .x = i, .y = j, .count = count });
            }
        }
        
        var removed: usize = 0;
        for (all_neighbors.items) |cell| {
            if (cell.count < 4) {
                grid.items[cell.x].items[cell.y] = 'x';
                removed += 1;
            }
        }
        
        iterations += 1;
        total_removed += removed;
        if (removed == 0) break;
    }
    
    print("{}\n", .{total_removed});
}

fn countNeighbors(grid: *const List(List(u8)), x: usize, y: usize) usize {
    const directions = [_][2]i32{
        .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
        .{ 0, -1 }, .{ 0, 1 },
        .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 },
    };
    
    var count: usize = 0;
    for (directions) |dir| {
        const nx = @as(i32, @intCast(x)) + dir[0];
        const ny = @as(i32, @intCast(y)) + dir[1];
        
        if (nx >= 0 and nx < grid.items.len and ny >= 0 and ny < grid.items[0].items.len) {
            const ux = @as(usize, @intCast(nx));
            const uy = @as(usize, @intCast(ny));
            if (grid.items[ux].items[uy] == '@') {
                count += 1;
            }
        }
    }
    
    return count;
}

fn removeMarked(grid: *List(List(u8)), mark: u8) void {
    for (grid.items) |row| {
        for (row.items, 0..) |cell, j| {
            if (cell == mark) {
                row.items[j] = '.';
            }
        }
    }
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
