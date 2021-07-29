const std = @import("std");
const ansi = @import("ansi");
const range = @import("range").range;

pub fn answer(comptime prompt: []const u8, comptime T: type, comptime valfmt: []const u8, value: T) T {
    std.debug.print(comptime ansi.color.Fg(.Green, "? "), .{});
    std.debug.print(comptime ansi.color.Bold(prompt ++ " "), .{});
    std.debug.print(comptime ansi.color.Fg(.Cyan, valfmt ++ "\n"), .{value});
    return value;
}

const PromptRet = struct {
    n: usize,
    value: []const u8,
};

fn doprompt(in: std.fs.File.Reader, alloc: *std.mem.Allocator, default: ?[]const u8) !PromptRet {
    var n: usize = 1;
    var value: []const u8 = undefined;
    while (true) : (n += 1) {
        std.debug.print(comptime ansi.color.Faint("> "), .{});
        const input = try in.readUntilDelimiterAlloc(alloc, '\n', 100);

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

fn clean(n: usize) void {
    for (range(n)) |_| {
        std.debug.print(comptime ansi.csi.CursorUp(1), .{});
        std.debug.print(comptime ansi.csi.EraseInLine(0), .{});
    }
}

pub fn forEnum(comptime prompt: []const u8, alloc: *std.mem.Allocator, comptime options: type, default: ?options) !options {
    comptime std.debug.assert(@typeInfo(options) == .Enum);

    std.debug.print(comptime ansi.color.Fg(.Green, "? "), .{});
    std.debug.print(comptime ansi.color.Bold(prompt ++ " "), .{});

    std.debug.print(ansi.style.Faint ++ "(", .{});
    inline for (std.meta.fields(options)) |f, i| {
        if (i != 0) std.debug.print("/", .{});
        std.debug.print(f.name, .{});
    }
    std.debug.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});

    const stdin = std.io.getStdIn().reader();
    var value: options = undefined;
    var i: usize = 0;
    while (true) {
        const def: ?[]const u8 = if (default) |d| @tagName(d) else null;
        const p = try doprompt(stdin, alloc, def);
        defer if (!std.mem.eql(u8, p.value, def orelse "")) alloc.free(p.value);

        i += p.n;
        if (std.meta.stringToEnum(options, p.value)) |cap| {
            value = cap;
            break;
        }
    }
    clean(i);
    _ = answer(prompt, []const u8, "{s}", @tagName(value));

    return value;
}

pub fn forString(comptime prompt: []const u8, alloc: *std.mem.Allocator, default: ?[]const u8) ![]const u8 {
    std.debug.print(comptime ansi.color.Fg(.Green, "? "), .{});
    std.debug.print(comptime ansi.color.Bold(prompt ++ " "), .{});

    if (default != null) {
        std.debug.print(ansi.style.Faint ++ "(", .{});
        std.debug.print("{s}", .{default.?});
        std.debug.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});
    }

    const stdin = std.io.getStdIn().reader();
    const p = try doprompt(stdin, alloc, default);
    clean(p.n);
    return answer(prompt, []const u8, "{s}", p.value);
}

pub fn forConfirm(comptime prompt: []const u8, alloc: *std.mem.Allocator) !bool {
    return (try forEnum(prompt, alloc, enum { y, n }, .y)) == .y;
}

// pub fn forNumber(comptime prompt: []const u8, alloc: *std.mem.Allocator, comptime T: type, default: ?T) !T {
//     std.debug.print(comptime ansi.color.Fg(.Green, "? "), .{});
//     std.debug.print(comptime ansi.color.Bold(prompt ++ " "), .{});

//     if (default != null) {
//         std.debug.print(ansi.style.Faint ++ "(", .{});
//         std.debug.print("{d}", .{default.?});
//         std.debug.print(")" ++ ansi.style.ResetIntensity ++ " ", .{});
//     }

//     const stdin = std.io.getStdIn().reader();
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
