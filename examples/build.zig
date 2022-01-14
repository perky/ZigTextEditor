const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const all = b.getInstallStep();

    const exe_raylib = b.addExecutable("editor_raylib", "example_raylib.zig");
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
    exe_raylib.install();
    b.installFile("monofonto.otf", "bin/monofonto.otf");
    all.dependOn(&exe_raylib.step);

    var run = exe_raylib.run();
    const run_step = b.step("run", "Run");
    run_step.dependOn(&run.step);

    const web_raylib = b.addStaticLibrary("editor_raylib_wasm", "example_raylib_wasm.zig");
    web_raylib.linkLibC();
    web_raylib.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding
    });
    web_raylib.setBuildMode(mode);
    web_raylib.addIncludeDir("raylib");
    web_raylib.addPackagePath("text_editor", "../text_editor.zig");
    web_raylib.install();
}