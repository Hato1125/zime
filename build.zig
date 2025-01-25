const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addModule("zime", .{
        .root_source_file = b.path("src/zime.zig"),
        .target = target,
        .optimize = optimize,
    });

    const example = b.addExecutable(.{
        .name = "example",
        .root_source_file = b.path("example/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    example.root_module.addImport("zime", lib);
    example.linkLibC();
    example.linkSystemLibrary("SDL3");
    example.linkSystemLibrary("SDL3_image");
    b.installArtifact(example);
}
