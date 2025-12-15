# Common Zig Patterns Used in Solutions

This document provides a quick reference for the common patterns used throughout the translated Advent of Code solutions.

## Memory Management

### Basic List (Dynamic Array)
```zig
var list = List(i64).init(allocator);
defer list.deinit();

try list.append(42);
for (list.items) |item| {
    // use item
}
```

### Hash Map
```zig
var map = Map(usize, i64).init(allocator);
defer map.deinit();

try map.put(key, value);
if (map.get(key)) |value| {
    // use value
}
```

### String Hash Map
```zig
var str_map = StrMap(i64).init(allocator);
defer str_map.deinit();

try str_map.put("key", 42);
```

### Nested Structures
```zig
var grid = List(List(u8)).init(allocator);
defer {
    for (grid.items) |row| {
        row.deinit();
    }
    grid.deinit();
}
```

## String Processing

### Tokenizing by Character
```zig
var lines = tokenizeSca(u8, data, '\n');
while (lines.next()) |line| {
    // process line
}
```

### Splitting (keeps empty parts)
```zig
var parts = splitSca(u8, data, '\n');
while (parts.next()) |part| {
    // process part
}
```

### Trimming Whitespace
```zig
const trimmed = trim(u8, line, " \t\r\n");
```

### Parsing Numbers
```zig
const num = try parseInt(i64, str, 10);
const float_num = try parseFloat(f64, str);
```

## Common Algorithms

### Sorting
```zig
// Sort ascending
sort(i64, array.items, {}, asc(i64));

// Sort descending
sort(i64, array.items, {}, desc(i64));

// Custom comparator
sort(Point, array.items, {}, struct {
    fn lessThan(_: void, a: Point, b: Point) bool {
        return a.x < b.x;
    }
}.lessThan);
```

### Union-Find
```zig
var parent = try allocator.alloc(usize, n);
defer allocator.free(parent);

for (0..n) |i| {
    parent[i] = i;
}

fn find(parent: []usize, x: usize) usize {
    if (parent[x] != x) {
        parent[x] = find(parent, parent[x]); // path compression
    }
    return parent[x];
}

fn union(parent: []usize, x: usize, y: usize) bool {
    const rx = find(parent, x);
    const ry = find(parent, y);
    if (rx == ry) return false;
    parent[rx] = ry;
    return true;
}
```

### Grid Neighbor Iteration
```zig
const directions = [_][2]i32{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{ 0, -1 },              .{ 0, 1 },
    .{ 1, -1 },  .{ 1, 0 },  .{ 1, 1 },
};

for (directions) |dir| {
    const nx = @as(i32, @intCast(x)) + dir[0];
    const ny = @as(i32, @intCast(y)) + dir[1];
    if (nx >= 0 and nx < width and ny >= 0 and ny < height) {
        // process neighbor
    }
}
```

## Type Conversions

### Integer Conversions
```zig
const signed: i32 = @intCast(unsigned_value);
const unsigned: usize = @intCast(signed_value);
```

### Float Conversions
```zig
const float_val: f64 = @floatFromInt(int_val);
const int_val: i64 = @intFromFloat(float_val);
```

## BigInt Operations

### Basic BigInt Usage
```zig
const BigInt = std.math.big.int.Managed;

var big = BigInt.init(allocator);
defer big.deinit();

try big.set(42);
try big.setString(10, "12345678901234567890");

var result = BigInt.init(allocator);
defer result.deinit();

try result.add(&big.toConst(), &other.toConst());
try result.sub(&big.toConst(), &other.toConst());
try result.mul(&big.toConst(), &other.toConst());

const order = try big.order(other.toConst()); // .lt, .eq, or .gt
```

## Output

### Printing Results
```zig
print("{}\n", .{answer});           // Simple value
print("{s}\n", .{string});          // String
print("{d}\n", .{number});          // Decimal number
print("{x}\n", .{number});          // Hexadecimal
print("{} {}\n", .{a, b});          // Multiple values
```

## Error Handling

### Try for Propagation
```zig
const value = try functionThatMightFail();
```

### Optional Handling
```zig
if (optional_value) |value| {
    // use value
} else {
    // handle null
}

const value = optional_value orelse default_value;
const value = optional_value.?; // crash if null
```

## String Formatting

### Allocating Formatted Strings
```zig
const str = try std.fmt.allocPrint(allocator, "Value: {}", .{num});
defer allocator.free(str);
```

## Math Operations

### Absolute Value
```zig
const abs_val = if (x < 0) -x else x;
const abs_val = @abs(x); // for floating point
```

### Min/Max
```zig
const min = @min(a, b);
const max = @max(a, b);
```

### Modulo (handles negatives correctly)
```zig
const result = @mod(value, modulus);
```

### Division
```zig
const floor_div = @divFloor(a, b);
const truncate_div = @divTrunc(a, b);
```

## Common Imports

```zig
const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;

const util = @import("util.zig");
const gpa = util.gpa;

const tokenizeSca = std.mem.tokenizeScalar;
const splitSca = std.mem.splitScalar;
const trim = std.mem.trim;
const parseInt = std.fmt.parseInt;
const print = std.debug.print;
const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;
```

## Tips

1. **Always defer cleanup**: Use `defer` immediately after allocation
2. **Check bounds**: Zig doesn't have automatic bounds checking in ReleaseFast mode
3. **Use const when possible**: Helps catch errors and documents intent
4. **Prefer slices over pointers**: More idiomatic and safer
5. **Use labeled blocks for complex control flow**: `break :label value`
6. **Comptime when appropriate**: Can eliminate runtime overhead
7. **Error unions**: Functions that can fail return `!Type`

## Example: Complete Solution Structure

```zig
const std = @import("std");
const util = @import("util.zig");
const gpa = util.gpa;
const List = std.ArrayList;

const data = @embedFile("data/dayXX.txt");

pub fn main() !void {
    const allocator = gpa;
    
    // Part 1
    var result1 = try solvePart1(allocator);
    std.debug.print("{}\n", .{result1});
    
    // Part 2
    var result2 = try solvePart2(allocator);
    std.debug.print("{}\n", .{result2});
}

fn solvePart1(allocator: std.mem.Allocator) !i64 {
    var list = List(i64).init(allocator);
    defer list.deinit();
    
    // Implementation here
    
    return answer;
}

fn solvePart2(allocator: std.mem.Allocator) !i64 {
    // Implementation here
    return answer;
}
```
