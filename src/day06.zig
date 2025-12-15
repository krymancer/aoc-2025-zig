const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    const allocator = gpa;
    
    var lines_list = List([]const u8).init(allocator);
    defer lines_list.deinit();
    
    var lines = splitSca(u8, data, '\n');
    while (lines.next()) |line| {
        try lines_list.append(line);
    }
    
    // Remove empty last line if present
    if (lines_list.items.len > 0 and lines_list.items[lines_list.items.len - 1].len == 0) {
        _ = lines_list.pop();
    }
    
    // Parse matrix of numbers (last line is operations)
    const operations_line = lines_list.pop();
    
    var numbers = List(List(i64)).init(allocator);
    defer {
        for (numbers.items) |row| {
            row.deinit();
        }
        numbers.deinit();
    }
    
    for (lines_list.items) |line| {
        var row = List(i64).init(allocator);
        var tokens = tokenizeSca(u8, line, ' ');
        while (tokens.next()) |token| {
            const num = try parseInt(i64, token, 10);
            try row.append(num);
        }
        try numbers.append(row);
    }
    
    var operations = List(u8).init(allocator);
    defer operations.deinit();
    
    var op_tokens = tokenizeSca(u8, operations_line, ' ');
    while (op_tokens.next()) |token| {
        if (token.len == 1 and (token[0] == '+' or token[0] == '*')) {
            try operations.append(token[0]);
        }
    }
    
    // Part 1: Apply operations column-wise
    var results = List(i64).init(allocator);
    defer results.deinit();
    
    for (operations.items, 0..) |op, i| {
        var vals = List(i64).init(allocator);
        defer vals.deinit();
        
        for (numbers.items) |row| {
            if (i < row.items.len) {
                try vals.append(row.items[i]);
            }
        }
        
        const result = applyOperation(op, vals.items);
        try results.append(result);
    }
    
    var total: i64 = 0;
    for (results.items) |r| {
        total += r;
    }
    
    print("{}\n", .{total});
    
    // Part 2: Read column by column from right to left
    results.clearRetainingCapacity();
    
    const max_len = blk: {
        var max: usize = 0;
        for (lines_list.items) |line| {
            if (line.len > max) max = line.len;
        }
        break :blk max;
    };
    
    var col: usize = max_len;
    var current_numbers = List(i64).init(allocator);
    defer current_numbers.deinit();
    var operation: u8 = 0;
    
    while (col > 0) {
        col -= 1;
        var number_buf = List(u8).init(allocator);
        defer number_buf.deinit();
        
        var found_op = false;
        for (lines_list.items) |line| {
            if (col >= line.len) continue;
            const ch = line[col];
            
            if (ch == '*' or ch == '+') {
                operation = ch;
                if (number_buf.items.len > 0) {
                    // Reverse and parse
                    std.mem.reverse(u8, number_buf.items);
                    const num = try parseInt(i64, number_buf.items, 10);
                    try current_numbers.append(num);
                }
                
                // Apply operation
                const filtered = try filterNonZero(allocator, current_numbers.items);
                defer allocator.free(filtered);
                const result = applyOperation(operation, filtered);
                try results.append(result);
                
                current_numbers.clearRetainingCapacity();
                number_buf.clearRetainingCapacity();
                found_op = true;
                break;
            }
            
            if (ch >= '0' and ch <= '9') {
                try number_buf.append(ch);
            }
        }
        
        if (!found_op and number_buf.items.len > 0) {
            std.mem.reverse(u8, number_buf.items);
            const num = try parseInt(i64, number_buf.items, 10);
            try current_numbers.append(num);
        }
    }
    
    total = 0;
    for (results.items) |r| {
        total += r;
    }
    
    print("{}\n", .{total});
}

fn applyOperation(op: u8, vals: []const i64) i64 {
    if (vals.len == 0) return 0;
    
    if (op == '+') {
        var sum: i64 = 0;
        for (vals) |v| {
            sum += v;
        }
        return sum;
    } else if (op == '*') {
        var product: i64 = 1;
        for (vals) |v| {
            product *= v;
        }
        return product;
    }
    return 0;
}

fn filterNonZero(allocator: Allocator, vals: []const i64) ![]i64 {
    var result = List(i64).init(allocator);
    for (vals) |v| {
        if (v != 0) {
            try result.append(v);
        }
    }
    return result.toOwnedSlice();
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
