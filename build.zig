const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "xtxf",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(b.dependency("termbox2", .{}).path("."));
    exe.addCSourceFile(.{ .file = b.path("src/termbox_impl.c") });
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    unit_tests.addIncludePath(b.dependency("termbox2", .{}).path("."));
    unit_tests.addCSourceFile(.{ .file = b.path("src/termbox_impl.c") });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_unit_tests.step);

    const test_ok = b.addRunArtifact(exe);
    test_ok.addArgs(&.{"-t=short"});
    test_ok.expectExitCode(0);
    test_step.dependOn(&test_ok.step);
}
