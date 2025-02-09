const std = @import("std");
const builtin = @import("builtin");

const zime = @import("../zime.zig");

const c = @cImport({
    @cInclude("SDL3/SDL_properties.h");
    @cInclude("SDL3/SDL_blendmode.h");
    @cInclude("SDL3/SDL_surface.h");
    @cInclude("SDL3/SDL_render.h");
});

pub const BlendMode = enum(u32) {
    none = @intCast(c.SDL_BLENDMODE_NONE),
    blend = @intCast(c.SDL_BLENDMODE_BLEND),
    pma_blend = @intCast(c.SDL_BLENDMODE_BLEND_PREMULTIPLIED),
    add = @intCast(c.SDL_BLENDMODE_ADD),
    pma_add = @intCast(c.SDL_BLENDMODE_ADD_PREMULTIPLIED),
    mod = @intCast(c.SDL_BLENDMODE_MOD),
    mul = @intCast(c.SDL_BLENDMODE_MUL),
    invalid = @intCast(c.SDL_BLENDMODE_INVALID),
};

pub const ScaleMode = enum(i32) {
    nearest = @intCast(c.SDL_SCALEMODE_NEAREST),
    linear = @intCast(c.SDL_SCALEMODE_LINEAR),
};

pub const RenderBackend = enum {
    auto,
    metal,
    opengl,
    vulkan,
    direct3d11,
    direct3d12,
};

pub const RendererCreateError = error {
    InvalidWindow,
    InvalidBackend,
    PropertiesCreateFailed,
    RendererCreateFailed,
};

pub const RendererCreateInfo = struct {
    window: zime.Window,
    backend: RenderBackend,
};

pub const Renderer = struct {
    ptr: ?*c.SDL_Renderer,

    pub fn create(createInfo: RendererCreateInfo) RendererCreateError!Renderer {
        if (createInfo.window.ptr == null) {
            return RendererCreateError.InvalidWindow;
        }

        if (createInfo.backend != RenderBackend.auto) {
            switch (builtin.os.tag) {
                .linux => {
                    if (createInfo.backend == RenderBackend.opengl and createInfo.backend == RenderBackend.vulkan) {
                        return RendererCreateError.InvalidBackend;
                    }
                },
                .macos => {
                    if (createInfo.backend == RenderBackend.direct3d11 and createInfo.backend == RenderBackend.direct3d12) {
                        return RendererCreateError.InvalidBackend;
                    }
                },
                .windows => {
                    if (createInfo.backend == RenderBackend.metal and createInfo.backend == RenderBackend.vulkan) {
                        return RendererCreateError.InvalidBackend;
                    }
                },
                else => {
                    @compileError("Unsupported OS");
                }
            }
        }

        const props = c.SDL_CreateProperties();
        if (props == 0) {
            return RendererCreateError.PropertiesCreateFailed;
        }

        defer c.SDL_DestroyProperties(props);

        if (createInfo.backend != RenderBackend.auto) {
            _ = c.SDL_SetStringProperty(props, c.SDL_PROP_RENDERER_CREATE_NAME_STRING, @tagName(createInfo.backend));
        }

        _ = c.SDL_SetPointerProperty(props, c.SDL_PROP_RENDERER_CREATE_WINDOW_POINTER, createInfo.window.ptr);

        const renderer = c.SDL_CreateRendererWithProperties(props);
        if (renderer) |ptr| {
            return .{ .ptr = ptr };
        }

        return RendererCreateError.RendererCreateFailed;
    }

    pub fn destroy(self: *Renderer) void {
        if (self.ptr) |ptr| {
            c.SDL_DestroyRenderer(ptr);
            self.ptr = null;
        }
    }

    pub fn clear(self: Renderer) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_RenderClear(ptr);
        }
    }

    pub fn present(self: Renderer) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_RenderPresent(ptr);
        }
    }

    pub fn setSwapInterval(self: Renderer, interval: i32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderVSync(ptr, interval);
        }
    }

    pub fn getSwapInterval(self: Renderer) i32 {
        if (self.ptr) |ptr| {
            var interval: i32 = 0;
            _ = c.SDL_GetRenderVSync(ptr, &interval);
            return interval;
        }
        return 0;
    }

    pub fn isVSync(self: Renderer) bool {
        return self.getSwapInterval() > 0;
    }

    pub fn isAdaptiveSync(self: Renderer) bool {
        return self.getSwapInterval() == -1;
    }

    pub fn setDrawColor(self: Renderer, color: zime.RGBAColor) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderDrawColor(ptr, color.r, color.g, color.b, color.a);
        }
    }

    pub fn getDrawColor(self: Renderer) zime.RGBAColor {
        if (self.ptr) |ptr| {
            var r: u8 = 0;
            var g: u8 = 0;
            var b: u8 = 0;
            var a: u8 = 0;
            _ = c.SDL_GetRenderDrawColor(ptr, &r, &g, &b, &a);

            return .{ .r = r, .g = g, .b = b, .a = a };
        }
        return .{ .r = 0, .g = 0, .b = 0, .a = 0 };
    }

    pub fn setScale(self: Renderer, width: f32, height: f32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderScale(ptr, width, height);
        }
    }

    pub fn getScale(self: Renderer) zime.Size(f32) {
        if (self.ptr) |ptr| {
            var width: f32 = 0.0;
            var height: f32 = 0.0;
            _ = c.SDL_GetRenderScale(ptr, &width, &height);

            return .{ .width = width, .height = height };
        }
        return .{ .width = 0.0, .height = 0.0 };
    }

    pub fn setViewport(self: Renderer, rect: zime.Rect(i32)) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderViewport(ptr, &c.SDL_Rect {
                .x = rect.x,
                .y = rect.y,
                .w = rect.width,
                .h = rect.height,
            });
        }
    }

    pub fn getViewport(self: Renderer) zime.Rect(i32) {
        if (self.ptr) |ptr| {
            var rect: c.SDL_Rect = undefined;
            _ = c.SDL_GetRenderViewport(ptr, &rect);

            return .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.w,
                .height = rect.h
            };
        }
        return .{
            .x = 0,
            .y = 0,
            .width = 0,
            .height = 0
        };
    }

    pub fn setClipRect(self: Renderer, rect: zime.Rect(i32)) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderClipRect(ptr, &c.SDL_Rect {
                .x = rect.x,
                .y = rect.y,
                .w = rect.width,
                .h = rect.height,
            });
        }
    }

    pub fn getClipRect(self: Renderer) zime.Rect(i32) {
        if (self.ptr) |ptr| {
            var rect: c.SDL_Rect = undefined;
            _ = c.SDL_GetRenderClipRect(ptr, &rect);

            return .{
                .x = rect.x,
                .y = rect.y,
                .width = rect.w,
                .height = rect.h
            };
        }
        return .{
            .x = 0,
            .y = 0,
            .width = 0,
            .height = 0
        };
    }

    pub fn setBlendMode(self: Renderer, mode: BlendMode) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetRenderDrawBlendMode(ptr, @intFromEnum(mode));
        }
    }

    pub fn getBlendMode(self: Renderer) BlendMode {
        if (self.ptr) |ptr| {
            var mode: c.SDL_BlendMode = undefined;
            _ = c.SDL_GetRenderDrawBlendMode(ptr, &mode);

            return @enumFromInt(mode);
        }
        return BlendMode.none;
    }

    pub fn getBackend(self: Renderer) RenderBackend {
        if (self.ptr) |ptr| {
            const str = c.SDL_GetRendererName(ptr);
            const len = std.mem.len(str);
            const name = str[0..len];

            if (std.mem.eql(u8, "metal", name)) {
                return RenderBackend.metal;
            } else if (std.mem.eql(u8, "opengl", name)) {
                return RenderBackend.opengl;
            } else if (std.mem.eql(u8, "vulkan", name)) {
                return RenderBackend.vulkan;
            } else if (std.mem.eql(u8, "direct3d11", name)) {
                return RenderBackend.direct3d11;
            } else if (std.mem.eql(u8, "direct3d12", name)) {
                return RenderBackend.direct3d12;
            }
        }
        return RenderBackend.auto;
    }
};