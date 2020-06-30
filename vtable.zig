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
    class: ClassesEnum,
    weight: i32,

    const talk = ClassVTable.Fn("talk");
    const weightG = ClassVTable.Fn("weightG");

    const ClassVTable = VTable(ClassesEnum, Classes);
    
    const ClassesEnum = enum {
        Dog,
        Cat,
        Frog
    };
    const Classes = .{
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



fn VTable (comptime ClassesEnum: type, comptime Classes: var) type {
    const enumInfo = @typeInfo(ClassesEnum);
    const classesInfo = @typeInfo(@TypeOf(Classes));
    
    if (enumInfo != .Enum)  @compileError("Enum is not an enum type");
    switch (classesInfo) 
    {
        .Struct => |data| {
            if (data.fields.len != enumInfo.Enum.fields.len) @compileError("ClassEnum and Structs are not even");
            for (data.fields) |field| 
                if (!@hasField(ClassesEnum, field.name)) 
                    @compileError("ClassEnum and Structs are not even");
        },
        else => @compileError("Not a struct")
    }
    
    return struct {

        fn ReturnType(comptime funcName: []const u8) type {
            return @typeInfo(@TypeOf(@field(@field(Classes, classesInfo.Struct.fields[0].name), funcName))).Fn.return_type.?;
        }
        fn FunctionType(comptime funcName: []const u8) type {
            return @TypeOf(@field(@field(Classes, classesInfo.Struct.fields[0].name), funcName));
        }
        pub fn Fn(comptime funcName: []const u8) (fn(var, var) ReturnType(funcName)) {
            
            const fnArray = br: {
                var _fnArray: [classesInfo.Struct.fields.len] FunctionType(funcName) = undefined;
                for (classesInfo.Struct.fields) |field| _fnArray[@enumToInt(@field(ClassesEnum, field.name))] = @field(@field(Classes, field.name),funcName);
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

fn enumValue(comptime Enum: type, fieldName: []const u8) @TagType(Enum) {
    for(@typeInfo(Enum).Enum.data.fields) |field| {
        if (std.mem.compare(u8, field.name, fieldName, fieldName.len)) return @field(Enum, field.name);
    }
    @compileError("Not a field.");
}
