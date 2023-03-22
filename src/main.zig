const std = @import("std");

const uv = @cImport(@cInclude("uv.h"));

export fn uv_mutex_size() usize {
    return @sizeOf(uv.uv_mutex_t);
}

export fn uv_mutex_new(addr: *[@sizeOf(uv.uv_mutex_t)]u8) [*c]uv.uv_mutex_t {
    return @ptrCast(*uv.uv_mutex_t, @alignCast(@alignOf(uv.uv_mutex_t), addr));
}
