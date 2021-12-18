const std = @import("std");
const ansi = @import("ansi");
const range = @import("range").range;

pub fn answer(out: anytype, comptime prompt: []const u8, comptime T: type, comptime valfmt: []const u8, value: T) !T {
    try out.print(comptime ansi.color.Fg(.Green, "? "), .{});
    try out.print(comptime ansi.color.Bold(prompt ++ " "), .{});
    try out.print(comptime ansi.color.Fg(.Cyan, valfmt ++ "\n"), .{value});
    return value;
}

const PromptRet = struct {
    n: usize,
    value: []const u8,
};

fn doprompt(out: anytype, in: anytype, alloc: std.mem.Allocator, default: ?[]const u8) !PromptRet {
    var n: usize = 1;
    var value: []const u8 = undefined;
    while (true) : (n += 1) {
        try out.print(comptime ansi.color.Faint("> "), .{});
        var input: []const u8 = try in.readUntilDelimiterAlloc(alloc, '\n', 100);
        input = std.mem.trimRight(u8, input, "\r\n");

        if (input.len == 0) if (default) |d| {
            value = d;
            break;
        };
        if (input.len > 0) {
            value = input;
            break;
        }
    }
    return PromptRet{ .n = n, .value = value };
}

fn clean(out: anytype, n: usize) !void {
    for (range(n)) |_| {
        try out.print(comptime ansi.csi.CursorUp(1), .{});
        try out.print(comptime ansi.csi.EraseInLine(0), .{});
    }
}

pub fn forEnum(out: anytype, in: anytype, comptime prompt: []const u8, alloc: std.mem.Allocator, comptime options: type, default: ?options) !options {
    comptime std.debug.assert(@typeInfo(options) == .Enum);
    const def: ?[]const u8 = if (default) |d| @tagName(d) else null;

    try out.print(comptime ansi.color.Fg(.Green, "? "), .{});
    try out.print(comptime ansi.color.Bold(prompt ++ " "), .{});

    try out.print(ansi.style.Faint ++ "(", .{});
    inline for (std.meta.fields(options)) |f, i| {
        if (i != 0) try out.print("/", .{});
        if (std.mem.eql(u8, f.name, def orelse "")) {
            try out.print(ansi.style.ResetIntensity, .{});
            try out.print(comptime ansi.color.Fg(.Cyan, f.name), .{});
            try out.print(ansi.style.Faint, .{});
        } else try out.print(f.name, .{});
    }
    try out.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});

    var value: options = undefined;
    var i: usize = 0;
    while (true) {
        const p = try doprompt(out, in, alloc, def);
        defer if (!std.mem.eql(u8, p.value, def orelse "")) alloc.free(p.value);

        i += p.n;
        if (std.meta.stringToEnum(options, p.value)) |cap| {
            value = cap;
            break;
        }
    }
    try clean(out, i);
    _ = try answer(out, prompt, []const u8, "{s}", @tagName(value));

    return value;
}

pub fn forString(out: anytype, in: anytype, comptime prompt: []const u8, alloc: std.mem.Allocator, default: ?[]const u8) ![]const u8 {
    try out.print(comptime ansi.color.Fg(.Green, "? "), .{});
    try out.print(comptime ansi.color.Bold(prompt ++ " "), .{});

    if (default != null) {
        try out.print(ansi.style.Faint ++ "(", .{});
        try out.print("{s}", .{default.?});
        try out.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});
    }

    const p = try doprompt(out, in, alloc, default);
    try clean(out, p.n);
    return try answer(out, prompt, []const u8, "{s}", p.value);
}

pub fn forConfirm(out: anytype, in: anytype, comptime prompt: []const u8, alloc: std.mem.Allocator) !bool {
    return (try forEnum(out, in, prompt, alloc, enum { y, n }, .y)) == .y;
}

// pub fn forNumber(comptime prompt: []const u8, alloc: *std.mem.Allocator, comptime T: type, default: ?T) !T {
//     try out.print(comptime ansi.color.Fg(.Green, "? "), .{});
//     try out.print(comptime ansi.color.Bold(prompt ++ " "), .{});

//     if (default != null) {
//         try out.print(ansi.style.Faint ++ "(", .{});
//         try out.print("{d}", .{default.?});
//         try out.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});
//     }

//     var value: T = undefined;
//     var i: usize = 0;
//     while (true) {
//         const n = if (default != null) try std.fmt.allocPrint(alloc, "{d}", .{default}) else null;
//         defer if (n != null) alloc.free(n.?);
//         const p = try doprompt(stdin, alloc, if (default != null) n else null);
//         defer alloc.free(p.value);
//         i += p.n;
//         switch (@typeInfo(T)) {
//             .Int => {
//                 if (std.fmt.parseInt(T, p.value, 10) catch null) |cap| {
//                     value = cap;
//                     break;
//                 }
//             },
//             .Float => {
//                 if (std.fmt.parseFloat(T, p.value) catch null) |cap| {
//                     value = cap;
//                     break;
//                 }
//             },
//             else => @compileError("expected number type instead got: " ++ @typeName(T)),
//         }
//     }
//     clean(i);
//     _ = answer(prompt, T, "{d}", value);

//     return value;
// }
