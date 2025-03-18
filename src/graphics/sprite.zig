const std = @import("std");

const sdl = @import("../sdl.zig");
const zime = @import("../zime.zig");

pub const SpriteCreateError = error{
    InvalidRenderer,
    InvalidImage,
    SpriteCreateFailed,
};

pub const SpriteCreateInfo = struct {
    renderer: zime.Renderer,
    width: i32,
    height: i32,
};

pub const SpriteCreateFromImageInfo = struct {
    renderer: zime.Renderer,
    image: zime.Image,
};

pub const Sprite = struct {
    ptr: ?*sdl.SDL_Texture,
    renderer: ?*sdl.SDL_Renderer,
    rotate: f64,
    flip: zime.Point(bool),
    scale: zime.Point(f32),
    render_origin: zime.Direction,
    rotate_origin: zime.Direction,

    pub fn create(createInfo: SpriteCreateInfo) SpriteCreateError!Sprite {
        if (createInfo.renderer.ptr == null) {
            return SpriteCreateError.InvalidRenderer;
        }

        const texture = sdl.SDL_CreateTexture(
            @ptrCast(createInfo.renderer.ptr),
            sdl.SDL_PIXELFORMAT_RGBA8888,
            sdl.SDL_TEXTUREACCESS_TARGET,
            createInfo.width,
            createInfo.height
        );

        if (texture) |ptr| {
            return .{
                .ptr = ptr,
                .renderer = @ptrCast(createInfo.renderer.ptr),
                .rotate = 0.0,
                .flip = .{ .x = false, .y = false },
                .scale = .{ .x = 1.0, .y = 1.0 }, 
                .render_origin = .{
                    .x = zime.Horizontal.left,
                    .y = zime.Vertical.top
                },
                .rotate_origin = .{
                    .x = zime.Horizontal.left,
                    .y = zime.Vertical.top
                },
            };
        }

        return SpriteCreateError.SpriteCreateFailed;
    }

    pub fn createFromImage(createInfo: SpriteCreateFromImageInfo) SpriteCreateError!Sprite {
        if (createInfo.renderer.ptr == null) {
            return SpriteCreateError.InvalidRenderer;
        }

        if (createInfo.image.ptr == null) {
            return SpriteCreateError.InvalidImage;
        }

        const texture = sdl.SDL_CreateTextureFromSurface(
            @ptrCast(createInfo.renderer.ptr),
            @ptrCast(createInfo.image.ptr)
        );

        if (texture) |ptr| {
             return .{
                .ptr = ptr,
                .renderer = @ptrCast(createInfo.renderer.ptr),
                .rotate = 0.0,
                .flip = .{ .x = false, .y = false },
                .scale = .{ .x = 1.0, .y = 1.0 },
                .render_origin = .{
                    .x = zime.Horizontal.left,
                    .y = zime.Vertical.top
                },
                .rotate_origin = .{
                    .x = zime.Horizontal.left,
                    .y = zime.Vertical.top
                },
            };
        }

        return SpriteCreateError.SpriteCreateFailed;
    }

    pub fn destroy(self: *Sprite) void {
        if (self.ptr) |ptr| {
            sdl.SDL_DestroyTexture(ptr);
            self.ptr = null;
            self.renderer = null;
        }
    }

    pub fn renderClip(self: Sprite, pos: zime.Point(f32), clip: zime.Rect(i32)) void {
        if (self.ptr) |ptr| {
            if (self.renderer) |renderer| {
                const src_rect = sdl.SDL_FRect {
                    .x = @floatFromInt(clip.x),
                    .y = @floatFromInt(clip.y),
                    .w = @floatFromInt(clip.width),
                    .h = @floatFromInt(clip.height),
                };

                var dst_rect = sdl.SDL_FRect {
                    .x = pos.x,
                    .y = pos.y,
                    .w = src_rect.w * self.scale.x,
                    .h = src_rect.h * self.scale.y,
                };

                dst_rect.x -= calcHorizontalOrigin(self.render_origin.x, dst_rect.w);
                dst_rect.y -= calcVerticalOrigin(self.render_origin.y, dst_rect.h);

                const rotate_origin = sdl.SDL_FPoint {
                    .x = calcHorizontalOrigin(self.rotate_origin.x, dst_rect.w),
                    .y = calcVerticalOrigin(self.rotate_origin.y, dst_rect.h),
                };

                const flip = @intFromBool(self.flip.x) * sdl.SDL_FLIP_HORIZONTAL
                    | @intFromBool(self.flip.y) * sdl.SDL_FLIP_VERTICAL;

                _ = sdl.SDL_RenderTextureRotated(
                    renderer,
                    ptr,
                    &src_rect,
                    &dst_rect,
                    self.rotate,
                    &rotate_origin,
                    @intCast(flip)
                );
            }
        }
    }

    pub fn render(self: Sprite, pos: zime.Point(f32)) void {
        const size = self.getSize();

        self.renderClip(pos, .{
            .x = 0,
            .y = 0,
            .width = size.width,
            .height = size.height,
        });
    }

    pub fn setOpacity(self: Sprite, opacity: u8) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetTextureAlphaMod(ptr, opacity);
        }
    }

    pub fn getOpacity(self: Sprite) u8 {
        if (self.ptr) |ptr| {
            var opacity: u8 = 0;
            _ = sdl.SDL_SetTextureAlphaMod(ptr, &opacity);

            return opacity;
        }
        return 0;
    }

    pub fn setColor(self: Sprite, color: zime.RGBColor) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetTextureColorMod(ptr, color.r, color.g, color.b);
        }
    }

    pub fn getColor(self: Sprite) zime.RGBColor {
        if (self.ptr) |ptr| {
            var r = 0;
            var g = 0;
            var b = 0;
            _ = sdl.SDL_GetTextureColorMod(ptr, &r, &g, &b);

            return .{ .r = r, .g = g, .b = b };
        }
        return .{ .r = 0, .g = 0, .b = 0 };
    }

    pub fn setBlendMode(self: Sprite, mode: zime.BlendMode) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetTextureBlendMode(ptr, @intFromEnum(mode));
        }
    }

    pub fn getBlendMode(self: Sprite) zime.BlendMode {
        if (self.ptr) |ptr| {
            var mode: sdl.SDL_BlendMode = undefined;
            _ = sdl.SDL_GetTextureBlendMode(ptr, &mode);

            return @enumFromInt(mode);
        }
        return zime.BlendMode.none;
    }

    pub fn setScaleMode(self: Sprite, mode: zime.BlendMode) void {
        if (self.ptr) |ptr| {
            _ = sdl.SDL_SetTextureScaleMode(ptr, @intFromEnum(mode));
        }
    }

    pub fn getScaleMode(self: Sprite) zime.BlendMode {
        if (self.ptr) |ptr| {
            var mode: sdl.SDL_ScaleMode = undefined;
            _ = sdl.SDL_GetTextureScaleMode(ptr, &mode);

            return @enumFromInt(mode);
        }
        return zime.ScaleMode.none;
    }

    pub fn getSize(self: Sprite) zime.Size(i32) {
        if (self.ptr) |ptr| {
            var width: f32 = 0.0;
            var height: f32 = 0.0;
            _ = sdl.SDL_GetTextureSize(ptr, &width, &height);

            return .{
                .width = @intFromFloat(width),
                .height = @intFromFloat(height),
            };
        }
        return .{ .width = 0, .height = 0 };
    }

    fn calcHorizontalOrigin(dire: zime.Horizontal, width: f32) f32 {
        switch(dire) {
            .left => return 0.0,
            .center => return width / 2.0,
            .right => return width,
        }
    }

    fn calcVerticalOrigin(dire: zime.Vertical, height: f32) f32 {
        switch(dire) {
            .top => return 0.0,
            .center => return height / 2.0,
            .bottom => return height,
        }
    }
};
