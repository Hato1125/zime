const std = @import("std");

const zime = @import("../zime.zig");

const c = @cImport({
    @cInclude("SDL3/SDL_init.h");
    @cInclude("SDL3/SDL_main.h");
});

pub const AppInitError = error{
    VideoInitFailure,
    AudioInitFailure,
    EventsInitFailure,
    GamepadInitFailure,
};

pub const AppCreateInfo = struct {
    window: struct {
        title: []const u8,
        x: i32,
        y: i32,
        width: i32,
        height: i32,
    },
    renderer: struct {
        backend: zime.RenderBackend,
    },
};

pub const AppLoopCallback = struct {
    begin: ?fn () void,
    end: ?fn () void,
    update: ?fn () void,
    render: ?fn () void,
};

pub const App = struct {
    window: zime.Window,
    renderer: zime.Renderer,
    framerate: struct {
        max: u32,
        limit: bool,
    },

    pub fn init(info: AppCreateInfo) (AppInitError || zime.WindowCreateError || zime.RendererCreateError)!App {
        c.SDL_SetMainReady();

        const Subsystem = struct {
            kind: u32,
            err: AppInitError,
        };

        const subsystems = [_]Subsystem{
            .{ .kind = c.SDL_INIT_VIDEO, .err = AppInitError.VideoInitFailure },
            .{ .kind = c.SDL_INIT_AUDIO, .err = AppInitError.AudioInitFailure },
            .{ .kind = c.SDL_INIT_EVENTS, .err = AppInitError.EventsInitFailure },
            .{ .kind = c.SDL_INIT_GAMEPAD, .err = AppInitError.GamepadInitFailure },
        };

        for (subsystems) |subsystem| {
            if (c.SDL_WasInit(subsystem.kind) == 0) {
                if (!c.SDL_InitSubSystem(subsystem.kind)) {
                    return subsystem.err;
                }
                errdefer c.SDL_QuitSubSystem(subsystem.kind);
            }
        }

        var window = try zime.Window.create(.{
            .title = info.window.title,
            .x = info.window.x,
            .y = info.window.y,
            .width = info.window.width,
            .height = info.window.height,
        });
        errdefer window.destroy();

        var renderer = try zime.Renderer.create(.{
            .window = window,
            .backend = info.renderer.backend,
        });
        errdefer renderer.destroy();

        return .{
            .window = window,
            .renderer = renderer,
            .framerate = .{
                .max = 120,
                .limit = true,
            },
        };
    }

    pub fn finish(self: *App) void {
        self.renderer.destroy();
        self.window.destroy();

        c.SDL_Quit();
    }

    pub fn loop(self: App, callback: AppLoopCallback) void {
        var event_queue: c.SDL_Event = undefined;

        var next_time = std.time.nanoTimestamp() + self.calcFrameNanosecond();

        while (true) {
            if (callback.begin) |begin| {
                begin();
            }

            while (c.SDL_PollEvent(&event_queue)) {
                if (event_queue.type == c.SDL_EVENT_QUIT) {
                    return;
                }
            }

            if (callback.update) |update| {
                update();
            }

            self.renderer.clear();

            if (callback.render) |render| {
                render();
            }

            self.renderer.present();

            if (callback.end) |end| {
                end();
            }

            if (self.framerate.limit) {
                next_time += self.calcFrameNanosecond();

                // The drift caused by using a variable is extremely small—likely too small
                // for sleep to compensate—so we keep it as a variable.
                const now_time = std.time.nanoTimestamp();
                const sleep_time = next_time - now_time;
                if (sleep_time <= 0) {
                    next_time = now_time;
                } else {
                    std.time.sleep(@intCast(sleep_time));
                }
            }
        }
    }

    fn calcFrameNanosecond(self: App) i128 {
        return 1_000_000_000 / self.framerate.max;
    }
};
