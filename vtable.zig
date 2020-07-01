const std = @import("std");

pub fn CreateVTable (comptime TagT: type, comptime Table: type, comptime implementingType: enum { Struct, Union }) type {
    const enumInfo = @typeInfo(TagT);
    const tableInfo = @typeInfo(Table);
    
    if (enumInfo != .Enum)  @compileError("Enum is not an enum type");
    switch (tableInfo) 
    {
        .Struct => |data| {
            if (data.decls.len != enumInfo.Enum.fields.len) @compileError("ClassEnum and Structs are not even");
            for (data.decls) |decl| 
                if (!@hasField(TagT, decl.name)) 
                    @compileError("ClassEnum and Structs are not even");
        },
        else => @compileError("Not a struct")
    }

    const tabledecls = tableInfo.Struct.decls;
    
    return struct {
        pub const TagType = TagT;
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
                    _fnArray[@enumToInt(@field(TagT, decl.name))] = @field(@field(Table, decl.name),funcName);
                break :br &_fnArray;
            };

            if (implementingType == .Union)
                return struct {
                    fn _func(self: var, args: var) ReturnType(funcName) {
                    
                        return @call(.{}, fnArray[@enumToInt(self.*)], .{ self } ++ args );
                    }
                }._func
            else
                return struct {
                    fn _func(self: var, args: var) ReturnType(funcName) {
                        const tagName = 
                            comptime for(@typeInfo(@TypeOf(self.*)).Struct.fields) |field| {
                                if (field.field_type == TagT) break field.name
                                else switch (@typeInfo(field.field_type)) {
                                    .Union => |unionInfo| { if (unionInfo.tag_type == TagT) break field.name;  }, 
                                    else => continue
                                }
                            };
                        

                        return @call(.{}, fnArray[@enumToInt(@field(self, tagName))], .{ self } ++ args );
                    }
                }._func;
        }
    };
}
