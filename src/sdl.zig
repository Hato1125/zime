pub const sdl = @cImport({
    @cInclude("SDL3/SDL_properties.h");
    @cInclude("SDL3/SDL_init.h");
    @cInclude("SDL3/SDL_main.h");
    @cInclude("SDL3/SDL_video.h");
    @cInclude("SDL3/SDL_blendmode.h");
    @cInclude("SDL3/SDL_surface.h");
    @cInclude("SDL3/SDL_render.h");
    @cInclude("SDL3_image/SDL_image.h");
    @cInclude("SDL3_gfx/SDL3_gfxPrimitives.h");
});

pub usingnamespace sdl;
