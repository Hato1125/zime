const std = @import("std");

const zime = @import("../zime.zig");

const c = @cImport({
    @cInclude("SDL3/SDL_properties.h");
    @cInclude("SDL3/SDL_video.h");
});

pub const WindowCreateError = error{
    PropertiesCreateFailed,
    WindowCreateFailed,
};

pub const WindowCreateInfo = struct {
    title: []const u8,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
};

pub const Window = struct {
    ptr: ?*c.SDL_Window,

    pub fn create(info: WindowCreateInfo) WindowCreateError!Window {
        const props = c.SDL_CreateProperties();
        if (props == 0) {
            return WindowCreateError.PropertiesCreateFailed;
        }

        defer c.SDL_DestroyProperties(props);

        _ = c.SDL_SetStringProperty(props, c.SDL_PROP_WINDOW_CREATE_TITLE_STRING, &info.title[0]);
        _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_X_NUMBER, info.x);
        _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_Y_NUMBER, info.y);

        // If a value less than or equal to 0 is specified for the size, an error will occur during creation,
        // so it must be a value greater than or equal to 1.
        _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER, std.math.clamp(info.width, 1, std.math.maxInt(i32)));
        _ = c.SDL_SetNumberProperty(props, c.SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER, std.math.clamp(info.height, 1, std.math.maxInt(i32)));

        const window = c.SDL_CreateWindowWithProperties(props);
        if (window) |ptr| {
            return .{ .ptr = ptr };
        }

        return WindowCreateError.WindowCreateFailed;
    }

    pub fn destroy(self: *Window) void {
        if (self.ptr) |ptr| {
            c.SDL_DestroyWindow(ptr);
            self.ptr = null;
        }
    }

    pub fn show(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_ShowWindow(ptr);
        }
    }

    pub fn hide(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_HideWindow(ptr);
        }
    }

    pub fn maximized(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_MaximizeWindow(ptr);
        }
    }

    pub fn minimized(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_MinimizeWindow(ptr);
        }
    }

    pub fn fullscreen(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowFullscreen(ptr, true);
        }
    }

    pub fn isFullscreen(self: Window) bool {
        if (self.ptr) |ptr| {
            return c.SDL_GetWindowFlags(ptr) & c.SDL_WINDOW_FULLSCREEN != 0;
        }
        return false;
    }

    pub fn windowed(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowFullscreen(ptr, false);
        }
    }

    pub fn isWindowed(self: Window) bool {
        if (self.ptr) |ptr| {
            return c.SDL_GetWindowFlags(ptr) & c.SDL_WINDOW_FULLSCREEN == 0;
        }
        return false;
    }

    pub fn enableResizable(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowResizable(ptr, true);
        }
    }

    pub fn disableResizable(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowResizable(ptr, false);
        }
    }

    pub fn isResizable(self: Window) bool {
        if (self.ptr) |ptr| {
            return c.SDL_GetWindowFlags(ptr) & c.SDL_WINDOW_RESIZABLE != 0;
        }
        return false;
    }

    pub fn enableBorderless(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowBordered(ptr, false);
        }
    }

    pub fn disableBorderless(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowBordered(ptr, true);
        }
    }

    pub fn isBorderless(self: Window) bool {
        if (self.ptr) |ptr| {
            return c.SDL_GetWindowFlags(ptr) & c.SDL_WINDOW_BORDERLESS != 0;
        }
        return false;
    }

    pub fn enableAlwaysOnTop(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowAlwaysOnTop(ptr, true);
        }
    }

    pub fn disableAlwaysOnTop(self: Window) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowAlwaysOnTop(ptr, false);
        }
    }

    pub fn isAlwaysOnTop(self: Window) bool {
        if (self.ptr) |ptr| {
            return c.SDL_GetWindowFlags(ptr) & c.SDL_WINDOW_ALWAYS_ON_TOP != 0;
        }
        return false;
    }

    pub fn setIcon(self: Window, icon: zime.Image) void {
        if (self.ptr) |ptr| {
            if (icon.ptr) |image| {
                _ = c.SDL_SetWindowIcon(ptr, @ptrCast(image));
            }
        }
    }

    pub fn setSize(self: Window, width: i32, height: i32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowSize(
                ptr,
                std.math.clamp(width, 1, std.math.maxInt(i32)),
                std.math.clamp(height, 1, std.math.maxInt(i32)),
            );
        }
    }

    pub fn getSize(self: Window) zime.Size(i32) {
        if (self.ptr) |ptr| {
            var width: i32 = 0;
            var height: i32 = 0;
            _ = c.SDL_GetWindowSize(ptr, &width, &height);

            return .{ .width = width, .height = height };
        }
        return .{ .width = 0, .height = 0 };
    }

    pub fn setMaxSize(self: Window, width: i32, height: i32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowMaximumSize(
                ptr,
                std.math.clamp(width, 1, std.math.maxInt(i32)),
                std.math.clamp(height, 1, std.math.maxInt(i32)),
            );
        }
    }

    pub fn getMaxSize(self: Window) zime.Size(i32) {
        if (self.ptr) |ptr| {
            var width: i32 = 0;
            var height: i32 = 0;
            _ = c.SDL_GetWindowMaximumSize(ptr, &width, &height);

            return .{ .width = width, .height = height };
        }
        return .{ .width = 0, .height = 0 };
    }

    pub fn setMinSize(self: Window, width: i32, height: i32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowMinimumSize(
                ptr,
                std.math.clamp(width, 1, std.math.maxInt(i32)),
                std.math.clamp(height, 1, std.math.maxInt(i32)),
            );
        }
    }

    pub fn getMinSize(self: Window) zime.Size(i32) {
        if (self.ptr) |ptr| {
            var width: i32 = 0;
            var height: i32 = 0;
            _ = c.SDL_GetWindowMinimumSize(ptr, &width, &height);

            return .{ .width = width, .height = height };
        }
        return .{ .width = 0, .height = 0 };
    }

    pub fn setPos(self: Window, x: i32, y: i32) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowPosition(ptr, x, y);
        }
    }

    pub fn getPos(self: Window) zime.Point(i32) {
        if (self.ptr) |ptr| {
            var x: i32 = 0;
            var y: i32 = 0;
            _ = c.SDL_GetWindowPosition(ptr, &x, &y);

            return .{ .x = x, .y = y };
        }
        return .{ .x = 0, .y = 0 };
    }

    pub fn setTitle(self: Window, title: []const u8) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowTitle(ptr, &title[0]);
        }
    }

    pub fn getTitle(self: Window) []const u8 {
        if (self.ptr) |ptr| {
            const str = c.SDL_GetWindowTitle(ptr);
            const len = std.mem.len(str);

            return str[0..len];
        }
        return "";
    }

    pub fn setOpacity(self: Window, opacity: u8) void {
        if (self.ptr) |ptr| {
            _ = c.SDL_SetWindowOpacity(ptr, @as(f32, @floatFromInt(opacity)) / 255.0);
        }
    }

    pub fn getOpacity(self: Window) u8 {
        if (self.ptr) |ptr| {
            return @intFromFloat(c.SDL_GetWindowOpacity(ptr) * 255.0);
        }
        return 0;
    }
};
