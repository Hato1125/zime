pub fn Point(comptime T: type) type {
    return struct {
        x: T,
        y: T,
    };
}