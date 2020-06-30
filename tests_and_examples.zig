const assert = @import("std").debug.assert;
const vtable = @import("vtable.zig");

const Animal = struct {
    class: VTable.TagType,
    weight: i32,

    const talk = VTable.Fn("talk");
    const weightG = VTable.Fn("weightG");

    const VTable = CreateVTable(Tag, Table);

    const Tag = enum {
        Dog,
        Cat,
        Frog
    };
    const Table = struct {
        const Dog = struct {
            fn talk(self: *Animal) []const u8 {
                return "Woof";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        };
        const Cat = struct {
            fn talk(self: *Animal) []const u8 {
                return "Meow";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        };
        const Frog = struct {
            fn talk(self: *Animal) []const u8 {
                return "Ribbit";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        };
    };
};

test "struct implementation" {

    const stdOut = std.io.getStdOut().outStream();

    var animal: Animal = .{ .class = .Dog, .weight = 10_000 }; 

    assert( std.mem.eql(u8, "Woof", animal.talk(.{})));
    assert( animal.weightG(.{}) == 10_000);

    animal.weight = 12_000;

    assert( animal.weightG(.{}) == 12_000);

    animal = .{ .class = .Cat, .weight = 3_000 };

    assert( std.mem.eql(u8, "Meow", animal.talk(.{})));
    assert( animal.weightG(.{}) == 3_000);

    animal = .{ .class = .Frog, .weight = 250 };

    assert( std.mem.eql(u8, "Ribbit", animal.talk(.{})));
    assert( animal.weightG(.{}) == 250);
}
