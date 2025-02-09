pub const Point = @import("type/point.zig").Point;
pub const Size = @import("type/size.zig").Size;
pub const Rect = @import("type/rect.zig").Rect;
pub const RGBColor = @import("type/color.zig").RGBColor;
pub const RGBAColor = @import("type/color.zig").RGBAColor;

pub const ImageLoadError = @import("core/image.zig").ImageLoadError;
pub const ImageSaveError = @import("core/image.zig").ImageSaveError;
pub const Image = @import("core/image.zig").Image;

pub const WindowCreateError = @import("core/window.zig").WindowCreateError;
pub const WindowCreateInfo = @import("core/window.zig").WindowCreateInfo;
pub const Window = @import("core/window.zig").Window;