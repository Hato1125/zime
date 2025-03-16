pub const Horizontal = enum {
    left,
    center,
    right,
};

pub const Vertical = enum {
    top,
    center,
    bottom,
};

pub const Direction = struct {
    x: Horizontal,
    y: Vertical,
};
