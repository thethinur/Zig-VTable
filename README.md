# Zig-VTable

This is an example of how you could implement a Tagged VTable

It works similar to a tagged union.

Here's how it works:

## First create a the Type for you Tag:
```Zig
const TagType = enum {
    A,
    B,
    C,
    ...
};
```

## Create the table to build the VTables from:
Notice the names are the same as the TagType. Similar to a union with a TagType.
```Zig

const Table = struct {
    pub const A = struct {
        pub fn func1(self: *ImplementingStruct, ...) { ... }
        pub fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    pub const B = struct {
        pub fn func1(self: *ImplementingStruct, ...) { ... }
        pub fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    pub const C = struct {
        pub fn func1(self: *ImplementingStruct, ...) { ... }
        pub fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    ...
};
```

## Create the Table:
The Simple part
```Zig
const VTable = CreateVTable(TagType, Table, .Struct);
```

## Give one of the fields the TagType and get the wrapper functions:
Any name for each is legal, just only have one field with TagType.
```Zig
pub const ImplementingStruct = struct {
    vtableTag: VTable.TagType, // this is just so you don't have to write your TagType twice if you rename you choose to rename it.
    unrelatedField: i32, // Just for show :)
    ...
    pub const func1 = VTable.Fn("func1");
    pub const func2 = VTable.Fn("func2");
    ...
};
```
## Alternatives
Eventually I'll make it so you can also do. 
### In an union:
```Zig
const VTable = CreateVTable(TagType, Table, .Union);

pub const ImplementingUnion = union(VTable.TagType) {
    A: A,
    B: B,
    C: C
    ...
    pub const func1 = VTable.Fn("func1");
    pub const func2 = VTable.Fn("func2");
    ...
};
```
### Or with union as the tag:
```Zig
const VTable = CreateVTable(TagType, Table, .Struct);

pub const ImplementingStruct = struct {
    vtableTag: union(VTable.TagType) { A: A, B: B, C: C, ... }, 
    unrelatedField: i32, // Just for show :)
    ...
    pub const func1 = VTable.Fn("func1");
    pub const func2 = VTable.Fn("func2");
    ...
};
```

## Finally how to call them:
To be able to call any of the functions you'll need a wrapper function. This implementation utilizes a generic wrapper for all functions. Hopefully it get's inlined.
```Zig
pub fn main() void {
    var runtimePolymorphism: ImplementingStruct = .{ .vtableTag = .A, ... }; 
    
    runtimePolymorphism.func1(.{ ... }); // Should execute Table.A.func1()!
    
    runtimePolymorphism.vtableTag = .B;
    
    runtimePolymorphism.func1(.{ ... }); // Should execute Table.B.func1()!
}
```




