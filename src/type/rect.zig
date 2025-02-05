pub fn Rect(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        width: T,
        height: T,
    };
}