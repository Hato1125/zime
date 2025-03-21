const std = @import("std");

const sdl = @import("../sdl.zig");
const zime = @import("../zime.zig");

pub const ImageLoadError = error{LoadFailed};
pub const ImageSaveError = error{SaveFailed};

pub const Image = struct {
    ptr: ?*sdl.SDL_Surface,

    pub fn load(path: []const u8) ImageLoadError!Image {
        const surface = sdl.IMG_Load(&path[0]);
        if (surface == null) {
            return ImageLoadError.LoadFailed;
        }

        return .{ .ptr = surface };
    }

    pub fn unload(self: *Image) void {
        if (self.ptr) |ptr| {
            sdl.SDL_DestroySurface(ptr);
            self.ptr = null;
        }
    }

    pub fn saveAVIF(self: Image, path: []const u8, quality: u8) ImageSaveError!void {
        if (self.ptr) |ptr| {
            if (!sdl.IMG_SaveAVIF(ptr, &path[0], std.math.clamp(quality, 0, 100))) {
                return ImageSaveError.SaveFailed;
            }
        }
    }

    pub fn saveJPG(self: Image, path: []const u8, quality: u8) ImageSaveError!void {
        if (self.ptr) |ptr| {
            if (!sdl.IMG_SaveJPG(ptr, &path[0], std.math.clamp(quality, 0, 100))) {
                return ImageSaveError.SaveFailed;
            }
        }
    }

    pub fn saveBMP(self: Image, path: []const u8) ImageSaveError!void {
        if (self.ptr) |ptr| {
            if (!sdl.SDL_SaveBMP(ptr, &path[0])) {
                return ImageSaveError.SaveFailed;
            }
        }
    }

    pub fn savePNG(self: Image, path: []const u8) ImageSaveError!void {
        if (self.ptr) |ptr| {
            if (!sdl.IMG_SavePNG(ptr, &path[0])) {
                return ImageSaveError.SaveFailed;
            }
        }
    }

    pub fn lock(self: Image) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_LockSurface(ptr);
        }
    }

    pub fn unlock(self: Image) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_UnlockSurface(ptr);
        }
    }

    pub fn writePixel(self: Image, x: i32, y: i32, color: zime.Color) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_WriteSurfacePixel(ptr, x, y, color.r, color.g, color.b, color.a);
        }
    }

    pub fn readPixel(self: Image, x: i32, y: i32) zime.Color {
        if (self.ptr) |ptr| {
            var r: u8 = 0;
            var g: u8 = 0;
            var b: u8 = 0;
            var a: u8 = 0;
            _ = sdl.SDL_ReadSurfacePixel(ptr, x, y, &r, &g, &b, &a);

            return .{ .r = r, .g = g, .b = b, .a = a };
        }
        return .{ .r = 0, .g = 0, .b = 0, .a = 0 };
    }

    pub fn setColor(self: Image, color: zime.RGBColor) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetSurfaceColorMod(ptr, color.r, color.g, color.b);
        }
    }

    pub fn getColor(self: Image) zime.RGBColor {
        if (self.ptr) |ptr| {
            var r: u8 = 0;
            var g: u8 = 0;
            var b: u8 = 0;
            _ = sdl.SDL_GetSurfaceColorMod(ptr, &r, &g, &b);

            return .{ .r = r, .g = g, .b = b };
        }
        return .{ .r = 0, .g = 0, .b = 0, .a = 0 };
    }

    pub fn setOpacity(self: Image, opacity: u8) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetSurfaceAlphaMod(ptr, opacity);
        }
    }

    pub fn getOpacity(self: Image) u8 {
        if (self.ptr) |ptr| {
            var opacity: u8 = 0.0;
            _ = sdl.SDL_GetSurfaceAlphaMod(ptr, &opacity);

            return opacity;
        }
        return 0;
    }
};
