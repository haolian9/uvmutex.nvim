const std = @import("std");

const uv = @cImport(@cInclude("uv.h"));
const allocator = std.heap.c_allocator;

export fn hal_uv_mutex_size() usize {
    return @sizeOf(uv.uv_mutex_t);
}

export fn hal_uv_mutex_new(addr: *[@sizeOf(uv.uv_mutex_t)]u8) [*c]uv.uv_mutex_t {
    return @ptrCast(*uv.uv_mutex_t, @alignCast(@alignOf(uv.uv_mutex_t), addr));
}

export fn hal_uv_mutex_create(addr: *usize) void {
    const mutex = allocator.create(uv.uv_mutex_t) catch |err| @panic(@errorName(err));
    addr.* = @ptrToInt(mutex);
}

export fn hal_uv_mutex_destroy(addr: *usize) void {
    allocator.destroy(@intToPtr(*uv.uv_mutex_t, addr.*));
}
