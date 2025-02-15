pub fn Size(comptime T: type) type {
    return struct {
        width: T,
        height: T,
    };
}