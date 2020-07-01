const std = @import("std");
const assert = std.debug.assert;
const vtable = @import("vtable.zig");
const CreateVTable = vtable.CreateVTable;

const AnimalStruct = struct {
    class: VTable.TagType,

    const talk = VTable.Fn("talk");
    const quickMath = VTable.Fn("quickMath");

    const VTable = CreateVTable(Tag, Table, .Struct);

    const Tag = enum {
        Dog,
        Cat,
        Frog
    };
    const Table = struct {
        pub const Dog = struct {
            pub fn talk(self: *AnimalStruct) []const u8 {
                return "Woof";
            }
            pub fn quickMath(self: *AnimalStruct, a: i32, b: i32) i32 {
                return a + b;
            }
        };
        pub const Cat = struct {
            pub fn talk(self: *AnimalStruct) []const u8 {
                return "Meow";
            }
            pub fn quickMath(self: *AnimalStruct, a: i32, b: i32) i32 {
                return a * b;
            }
        };
        pub const Frog = struct {
            pub fn talk(self: *AnimalStruct) []const u8 {
                return "Ribbit";
            }
            pub fn quickMath(self: *AnimalStruct, a: i32, b: i32) i32 {
                return std.math.sqrt(a * a + b * b);
            }
        };
    };
};





test "struct with tag implementation" {

    var animal: AnimalStruct = .{ .class = .Dog, }; 

    assert( std.mem.eql(u8, "Woof", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 7);

    animal = .{ .class = .Cat, };

    assert( std.mem.eql(u8, "Meow", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 12);

    animal = .{ .class = .Frog, };

    assert( std.mem.eql(u8, "Ribbit", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 5);
}

const AnimalStructWithUnion = struct {
    class: union(VTable.TagType) {
        Dog: i32,
        Cat: i32,
        Frog: i32,
    },

    const talk = VTable.Fn("talk");
    const quickMath = VTable.Fn("quickMath");

    const VTable = CreateVTable(Tag, Table, .Struct);

    const Tag = enum {
        Dog,
        Cat,
        Frog
    };
    const Table = struct {
        pub const Dog = struct {
            pub fn talk(self: *AnimalStructWithUnion) []const u8 {
                return "Woof";
            }
            pub fn quickMath(self: *AnimalStructWithUnion, a: i32, b: i32) i32 {
                return a + b;
            }
        };
        pub const Cat = struct {
            pub fn talk(self: *AnimalStructWithUnion) []const u8 {
                return "Meow";
            }
            pub fn quickMath(self: *AnimalStructWithUnion, a: i32, b: i32) i32 {
                return a * b;
            }
        };
        pub const Frog = struct {
            pub fn talk(self: *AnimalStructWithUnion) []const u8 {
                return "Ribbit";
            }
            pub fn quickMath(self: *AnimalStructWithUnion, a: i32, b: i32) i32 {
                return std.math.sqrt(a * a + b * b);
            }
        };
    };
};

test "struct with union implementation" { 
    var animal: AnimalStructWithUnion = .{ .class = .{ .Dog = 0} }; 

    assert( std.mem.eql(u8, "Woof", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 7);

    animal = .{ .class = .{ .Cat = 0 }};

    assert( std.mem.eql(u8, "Meow", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 12);

    animal = .{ .class = .{ .Frog = 0 }};

    assert( std.mem.eql(u8, "Ribbit", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 5);
}

const AnimalUnion = union(VTable.TagType) {
    Dog: i32,
    Cat: i32,
    Frog: i32,

    const talk = VTable.Fn("talk");
    const quickMath = VTable.Fn("quickMath");

    const VTable = CreateVTable(Tag, Table, .Union);

    const Tag = enum {
        Dog,
        Cat,
        Frog
    };
    const Table = struct {
        pub const Dog = struct {
            pub fn talk(self: *AnimalUnion) []const u8 {
                return "Woof";
            }
            pub fn quickMath(self: *AnimalUnion, a: i32, b: i32) i32 {
                return a + b;
            }
        };
        pub const Cat = struct {
            pub fn talk(self: *AnimalUnion) []const u8 {
                return "Meow";
            }
            pub fn quickMath(self: *AnimalUnion, a: i32, b: i32) i32 {
                return a * b;
            }
        };
        pub const Frog = struct {
            pub fn talk(self: *AnimalUnion) []const u8 {
                return "Ribbit";
            }
            pub fn quickMath(self: *AnimalUnion, a: i32, b: i32) i32 {
                return std.math.sqrt(a * a + b * b);
            }
        };
    };
};

test "union implementation" { 
    var animal: AnimalUnion = .{ .Dog = 0 }; 

    assert( std.mem.eql(u8, "Woof", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 7);

    animal = .{ .Cat = 0 };

    assert( std.mem.eql(u8, "Meow", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 12);

    animal = .{ .Frog = 0 };

    assert( std.mem.eql(u8, "Ribbit", animal.talk(.{})));
    assert( animal.quickMath(.{3, 4}) == 5);
}