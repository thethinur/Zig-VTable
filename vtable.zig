const std = @import("std");

pub fn main() !void {
    const stdOut = std.io.getStdOut().outStream();

    var animal: Animal = .{ .class = .Dog, .weight = 10_000 }; 
    try stdOut.print("{} {}grams\n", .{ animal.talk(.{}), animal.weightG(.{}) });
    animal.weight = 12_000;
    try stdOut.print("{} {}grams\n", .{ animal.talk(.{}), animal.weightG(.{}) });

    animal = .{ .class = .Cat, .weight = 3_000 };
    try stdOut.print("{} {}grams\n", .{ animal.talk(.{}), animal.weightG(.{}) });
    animal = .{ .class = .Frog, .weight = 250 };
    try stdOut.print("{} {}grams\n", .{ animal.talk(.{}), animal.weightG(.{}) });
}

const Animal = struct {
    class: VTable.Tag,
    weight: i32,

    const talk = VTable.Fn("talk");
    const weightG = VTable.Fn("weightG");

    const VTable = CreateVTable(Tag, Functions);
    
    const Tag = enum {
        Dog,
        Cat,
        Frog
    };
    const Functions = .{
        .Dog = struct {
            fn talk(self: *Animal) []const u8 {
                return "Woof";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        },
        .Cat = struct {
            fn talk(self: *Animal) []const u8 {
                return "Meow";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        },
        .Frog = struct {
            fn talk(self: *Animal) []const u8 {
                return "Ribbit";
            }
            fn weightG(self: *Animal) i32 {
                return self.weight;
            }
        }
    };
};



fn CreateVTable (comptime TagType: type, comptime Map: var) type {
    const enumInfo = @typeInfo(TagType);
    const classesInfo = @typeInfo(@TypeOf(Map));
    
    if (enumInfo != .Enum)  @compileError("Enum is not an enum type");
    switch (classesInfo) 
    {
        .Struct => |data| {
            if (data.fields.len != enumInfo.Enum.fields.len) @compileError("ClassEnum and Structs are not even");
            for (data.fields) |field| 
                if (!@hasField(TagType, field.name)) 
                    @compileError("ClassEnum and Structs are not even");
        },
        else => @compileError("Not a struct")
    }
    
    return struct {
        pub const Tag = TagType;
        fn ReturnType(comptime funcName: []const u8) type {
            return @typeInfo(@TypeOf(@field(@field(Map, classesInfo.Struct.fields[0].name), funcName))).Fn.return_type.?;
        }
        fn FunctionType(comptime funcName: []const u8) type {
            return @TypeOf(@field(@field(Map, classesInfo.Struct.fields[0].name), funcName));
        }
        pub fn Fn(comptime funcName: []const u8) (fn(var, var) ReturnType(funcName)) {
            
            const fnArray = br: {
                var _fnArray: [classesInfo.Struct.fields.len] FunctionType(funcName) = undefined;
                for (classesInfo.Struct.fields) |field|
                    _fnArray[@enumToInt(@field(TagType, field.name))] = @field(@field(Map, field.name),funcName);
                break :br &_fnArray;
            };

            return struct {
                fn _func(self: var, args: var) ReturnType(funcName) {

                    return @call(.{}, fnArray[@enumToInt(self.class)], .{ self } ++ args );
                }
            }._func;
        }
    };
}
