const std = @import("std");

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
