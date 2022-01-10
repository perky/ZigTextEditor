const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe_raylib = b.addExecutable("editor_raylib", "using_raylib.zig");
    exe_raylib.addPackagePath("text_editor", "../text_editor.zig");
    exe_raylib.addPackagePath("raylib", "raylib/raylib.zig");
    exe_raylib.setTarget(target);
    exe_raylib.setBuildMode(mode);
    exe_raylib.linkLibC();
    exe_raylib.addIncludeDir("..");
    exe_raylib.addIncludeDir("raylib");
    exe_raylib.addObjectFile(switch (target.getOsTag()) {
        .windows => "raylib/raylib.lib",
        .linux => "raylib/libraylib.a",
        else => @panic("Unsupported OS"),
    });
    switch (exe_raylib.target.toTarget().os.tag) {
        .windows => {
            exe_raylib.linkSystemLibrary("winmm");
            exe_raylib.linkSystemLibrary("gdi32");
            exe_raylib.linkSystemLibrary("opengl32");
        },
        .linux => {
            exe_raylib.linkSystemLibrary("GL");
            exe_raylib.linkSystemLibrary("rt");
            exe_raylib.linkSystemLibrary("dl");
            exe_raylib.linkSystemLibrary("m");
            exe_raylib.linkSystemLibrary("X11");
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    var run = exe_raylib.run();
    const run_step = b.step("run", "Run");
    run_step.dependOn(&run.step);
    
    b.installArtifact(exe_raylib);
}