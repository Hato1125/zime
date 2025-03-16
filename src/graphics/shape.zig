const zime = @import("../zime.zig");

const c = @cImport({
    @cInclude("SDL3/SDL_render.h");
    @cInclude("SDL3_gfx/SDL3_gfxPrimitives.h");
});

pub const Triangle = struct {
    renderer: *zime.Renderer,
    pos: struct {
        pos1: zime.Point(f32),
        pos2: zime.Point(f32),
        pos3: zime.Point(f32),
    },
    color: zime.RGBAColor,

    pub fn render(self: Triangle, pos: zime.Point(f32)) void {
        if (self.renderer.ptr) |renderer| {
            const bg_color = self.renderer.getDrawColor();

            const xs = [3]i16{
                @as(i16, @intFromFloat(pos.x + self.pos.pos1.x)),
                @as(i16, @intFromFloat(pos.x + self.pos.pos2.x)),
                @as(i16, @intFromFloat(pos.x + self.pos.pos3.x)),
            };

            const ys = [3]i16{
                @as(i16, @intFromFloat(pos.y + self.pos.pos1.y)),
                @as(i16, @intFromFloat(pos.y + self.pos.pos2.y)),
                @as(i16, @intFromFloat(pos.y + self.pos.pos3.y)),
            };

            _ = c.filledPolygonRGBA(
                @ptrCast(renderer),
                &xs[0],
                &ys[0],
                3,
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
            );

            _ = c.aapolygonRGBA(
                @ptrCast(renderer),
                &xs[0],
                &ys[0],
                3,
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
            );

            self.renderer.setDrawColor(bg_color);
        }
    }
};

pub const Rect = struct {
    renderer: *zime.Renderer,
    size: zime.Size(f32),
    color: zime.RGBAColor,

    pub fn render(self: Rect, pos: zime.Point(f32)) void {
        if (self.renderer.ptr) |renderer| {
            const bg_color = self.renderer.getDrawColor();

            self.renderer.setDrawColor(self.color);

            _ = c.SDL_RenderFillRect(@ptrCast(renderer), &c.SDL_FRect{
                .x = pos.x,
                .y = pos.y,
                .w = self.size.width,
                .h = self.size.height,
            });

            self.renderer.setDrawColor(bg_color);
        }
    }
};

pub const Circle = struct {
    renderer: *zime.Renderer,
    radius: f32,
    color: zime.RGBAColor,

    pub fn render(self: Circle, pos: zime.Point(f32)) void {
        if (self.renderer.ptr) |renderer| {
            const bg_color = self.renderer.getDrawColor();

            _ = c.filledCircleRGBA(
                @ptrCast(renderer),
                @as(i16, @intFromFloat(pos.x + self.radius)),
                @as(i16, @intFromFloat(pos.y + self.radius)),
                @as(i16, @intFromFloat(self.radius)),
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
            );

            _ = c.aacircleRGBA(
                @ptrCast(renderer),
                @as(i16, @intFromFloat(pos.x + self.radius)),
                @as(i16, @intFromFloat(pos.y + self.radius)),
                @as(i16, @intFromFloat(self.radius)),
                self.color.r,
                self.color.g,
                self.color.b,
                self.color.a,
            );

            self.renderer.setDrawColor(bg_color);
        }
    }
};
