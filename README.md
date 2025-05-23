# zig-inquirer

![loc](https://sloc.xyz/github/nektro/zig-inquirer)
[![license](https://img.shields.io/github/license/nektro/zig-inquirer.svg)](https://github.com/nektro/zig-inquirer/blob/master/LICENSE)
[![nektro @ github sponsors](https://img.shields.io/badge/sponsors-nektro-purple?logo=github)](https://github.com/sponsors/nektro)
[![Zig](https://img.shields.io/badge/Zig-0.14-f7a41d)](https://ziglang.org/)
[![Zigmod](https://img.shields.io/badge/Zigmod-latest-f7a41d)](https://github.com/nektro/zigmod)

A collection of utilities for prompting information from the user on the CLI

Adapted from https://github.com/SBoudrias/Inquirer.js

## Run example

```
zig build run
```

## Screenshots

![image](https://user-images.githubusercontent.com/5464072/127479686-fda8f860-a705-4fd6-9768-a3e1f53a6bc7.png)

## Usage

- `pub fn answer(writer, reader, comptime prompt: []const u8, value: []const u8) []const u8`
    - Prints just the done string.
- `pub fn forEnum(writer, reader, comptime prompt: []const u8, alloc: *std.mem.Allocator, comptime options: enum, default: ?options) !options`
    - Accepts an enum and prompts the user to pick on of the fields.
- `pub fn forString(writer, reader, comptime prompt: []const u8, alloc: *std.mem.Allocator, default: ?[]const u8) ![]const u8`
    - Base function, asks prompt and returns non-empty answer.
- `pub fn forConfirm(writer, reader, comptime prompt: []const u8, alloc: *std.mem.Allocator) !bool`
    - Calls `forEnum` with `y/n`

## TODO

- number (current implementation causes compiler crash)
- list with strings
- string password
- long list with autocomplete
- date
- time
