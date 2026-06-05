const std = @import("std");
const deps = @import("./deps.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.option(std.builtin.OptimizeMode, "mode", "") orelse .Debug;
    const disable_llvm = b.option(bool, "disable_llvm", "use the non-llvm zig codegen") orelse false;

    const exe = b.addExecutable(.{
        .name = "zig-inquirer",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = mode,
        }),
    });
    deps.addAllTo(exe);
    exe.use_llvm = !disable_llvm;
    exe.use_lld = !disable_llvm;
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test.zig"),
            .target = target,
            .optimize = mode,
        }),
    });
    deps.addAllTo(tests);
    tests.use_llvm = !disable_llvm;
    tests.use_lld = !disable_llvm;
    b.getInstallStep().dependOn(&tests.step);

    const test_step = b.step("test", "Run all library tests");
    const tests_run = b.addRunArtifact(tests);
    tests_run.setCwd(b.path("."));
    tests_run.has_side_effects = true;
    test_step.dependOn(&tests_run.step);
}
