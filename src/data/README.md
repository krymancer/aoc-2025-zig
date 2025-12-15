# Input Data Directory

This directory should contain your personal Advent of Code input files.

## Required Files

Place your puzzle inputs here with the following naming convention:

```
day01.txt
day02.txt
day03.txt
day04.txt
day05.txt
day06.txt
day07.txt
day08.txt
day09.txt
day10.txt
day11.txt
day12.txt
```

## Getting Your Input Files

1. Go to [Advent of Code 2025](https://adventofcode.com/2025)
2. Log in with your account
3. Navigate to each day's puzzle
4. Download your personalized input
5. Save it to this directory with the appropriate filename

## Important Note

⚠️ **Do NOT commit your input files to version control!**

Advent of Code's creator asks that participants not share their puzzle inputs publicly. These files are unique to your account and should remain private. The `.gitignore` file in this repository is configured to exclude `*.txt` files from this directory (except for `keep_directory_in_git.txt`).

## File Format

Each input file should be plain text, exactly as downloaded from the Advent of Code website. The Zig solutions use `@embedFile()` to read these files at compile time.

## Example

If you're working on Day 1 and have downloaded your input from:
```
https://adventofcode.com/2025/day/1/input
```

Save it as:
```
src/data/day01.txt
```

Then run:
```bash
zig build day01
```
