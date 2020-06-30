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
    const Functions = struct {
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



fn CreateVTable (comptime TagType: type, comptime Table: type) type {
    const enumInfo = @typeInfo(TagType);
    const tableInfo = @typeInfo(Table);
    
    if (enumInfo != .Enum)  @compileError("Enum is not an enum type");
    switch (tableInfo) 
    {
        .Struct => |data| {
            if (data.decls.len != enumInfo.Enum.fields.len) @compileError("ClassEnum and Structs are not even");
            for (data.decls) |decl| 
                if (!@hasField(TagType, decl.name)) 
                    @compileError("ClassEnum and Structs are not even");
        },
        else => @compileError("Not a struct")
    }

    const tabledecls = tableInfo.Struct.decls;
    
    return struct {
        pub const Tag = TagType;
        fn ReturnType(comptime funcName: []const u8) type {
            return @typeInfo(@TypeOf(@field(@field(Table, tabledecls[0].name), funcName))).Fn.return_type.?;
        }
        fn FunctionType(comptime funcName: []const u8) type {
            return @TypeOf(@field(@field(Table, tabledecls[0].name), funcName));
        }
        pub fn Fn(comptime funcName: []const u8) (fn(var, var) ReturnType(funcName)) {
            
            const fnArray = br: {
                var _fnArray: [tabledecls.len] FunctionType(funcName) = undefined;
                for (tabledecls) |decl|
                    _fnArray[@enumToInt(@field(TagType, decl.name))] = @field(@field(Table, decl.name),funcName);
                break :br &_fnArray;
            };

            return struct {
                fn _func(self: var, args: var) ReturnType(funcName) {
                    const tagName = comptime for(@typeInfo(@TypeOf(self.*)).Struct.fields) |field| {
                        if (field.field_type == TagType) break field.name;
                    } else @compileError("self is somehow not a struct");

                    return @call(.{}, fnArray[@enumToInt(@field(self, tagName))], .{ self } ++ args );
                }
            }._func;
        }
    };
}
}
