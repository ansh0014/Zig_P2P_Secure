const std=@import("std");
// gpu compute stub
pub const GpuContext=struct {
    allocator:std.mem.Allocator,
    enabled: bool,
    pub fn init(allocator:std.mem.Allocator) GpuContext{
        return GpuContext{
            .allocator=allocator,
            .enabled=false,
        };
    }
        // Initialize GPU context
        pub fn initGpu(self: *GpuContext)!void{
            _=self;
            std.debug.print("GPU compute not implemented yet\n", .{});
            return error.NotImplemented;
        }
        pub fn encryptGpu(self:*GpuContext,data:[]u8,key:[]const u8)!void{
            _=self;
            _=data;
            _=key;
            return error.NotImplemented;
        }
        pub fn deint(self: *GpuContext)void{
            _ = self;
        }

};