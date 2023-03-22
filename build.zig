const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    {
        const lib = b.addSharedLibrary("main", "src/main.zig", .unversioned);
        lib.linkLibC();
        lib.linkSystemLibrary("libuv");
        lib.setBuildMode(mode);
        lib.install();
    }
}
