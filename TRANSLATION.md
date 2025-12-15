# Translation from JavaScript to Zig

This repository contains Zig translations of the JavaScript solutions from [krymancer/aoc-2025](https://github.com/krymancer/aoc-2025).

## What's Been Translated

All 12 days of Advent of Code 2025 have been translated from JavaScript to Zig:

- **Day 01**: Dial rotation and password counting ✅
- **Day 02**: BigInt number ranges and palindromic patterns (⚠️ Part 2 incomplete)
- **Day 03**: Finding maximum joltage from digit combinations ✅
- **Day 04**: Grid neighbor counting with iterative removal ✅
- **Day 05**: Range merging and ID validation ✅
- **Day 06**: Column-wise matrix operations ✅
- **Day 07**: Beam splitting and timeline tracking ✅
- **Day 08**: Union-find algorithm for junction boxes ✅
- **Day 09**: Rectangle area calculations (⚠️ Part 2 simplified)
- **Day 10**: Gaussian elimination for light puzzles (⚠️ Part 2 incomplete)
- **Day 11**: Graph path counting with memoization ✅
- **Day 12**: Tree area validation ✅

## How to Use

### Prerequisites

- Zig 0.15.0 or compatible version
- Your personal Advent of Code input files

### Setup

1. Place your input files in `src/data/` directory:
   ```
   src/data/day01.txt
   src/data/day02.txt
   ...
   src/data/day12.txt
   ```

2. Build and run a specific day:
   ```bash
   zig build day01
   zig build day02
   # etc.
   ```

3. Or build all days:
   ```bash
   zig build install_all
   ```

## Translation Notes

### Completed Features

- All core algorithms translated to idiomatic Zig
- Memory management using the GPA allocator
- Standard library utilities used throughout
- Proper error handling with Zig's error system

### Known Limitations

Some complex parts were simplified or marked for future work:

1. **Day 02 Part 2**: The repeated pattern generation with arbitrary BigInt lengths is complex. Part 1 is complete.

2. **Day 09 Part 2**: The flood-fill algorithm for interior detection was simplified. The basic rectangle area calculation works.

3. **Day 10 Part 2**: The Gaussian elimination with joltage values and backtracking requires more complex matrix operations.

### Key Differences from JavaScript

1. **Memory Management**: Zig requires explicit memory allocation and deallocation. All `List` and `Map` structures are properly freed.

2. **BigInt**: JavaScript's native BigInt is replaced with `std.math.big.int.Managed` in Zig.

3. **String Handling**: Zig uses slices (`[]const u8`) instead of JavaScript strings. Parsing is more explicit.

4. **Error Handling**: Zig uses `try` for error propagation instead of JavaScript's try-catch.

5. **Type Safety**: Zig is statically typed, so all types are explicitly defined or inferred.

## File Structure

```
src/
├── data/           # Place your input files here (day01.txt, day02.txt, etc.)
├── day01.zig       # Day 1 solution
├── day02.zig       # Day 2 solution
├── ...
├── day12.zig       # Day 12 solution
└── util.zig        # Utility functions
```

## Building and Testing

### Build a single day
```bash
zig build day01
```

### Build all days
```bash
zig build install_all
```

### Run all days
```bash
zig build run_all
```

## Contributing

If you'd like to complete the simplified parts (Day 02 Part 2, Day 09 Part 2, Day 10 Part 2), contributions are welcome!

The main challenges are:
- Implementing efficient BigInt operations for large number generation
- Flood-fill algorithms for grid-based problems
- Complex matrix operations for Gaussian elimination

## Original JavaScript Source

The original JavaScript solutions can be found at:
https://github.com/krymancer/aoc-2025

## License

Same as the original repository.
