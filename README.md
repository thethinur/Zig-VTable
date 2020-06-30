# Zig-VTable

This is an example of how you could implement a Tagged VTable

It works similar to a tagged union.

Here's how it works:

## First create a the Type for you Tag:
```Zig
const TagType = struct {
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
    const A = struct {
        fn func1(self: *ImplementingStruct, ...) { ... }
        fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    const B = struct {
        fn func1(self: *ImplementingStruct, ...) { ... }
        fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    const C = struct {
        fn func1(self: *ImplementingStruct, ...) { ... }
        fn func2(self: *ImplementingStruct, ...) { ... }
        ...
    };
    ...
};
```

## Create the Table:
The Simple part
```Zig
const VTable = CreateVTable(TagType, Table);
```

## Give one of the fields the TagType and get the wrapper functions:
Any name for each is legal, just only have one field with TagType.
```Zig
const ImplementingStruct = struct {
    vtableTag: VTable.TagType, // this is just so you don't have to write your TagType twice if you rename you choose to rename it.
    unrelatedField: i32, // Just for show :)
    ...
    const func1 = VTable.Fn("func1");
    const func2 = VTable.Fn("func2");
    ...
};
```

## Finally how to call them:
To be able to call any of the functions you'll need a wrapper function. This implementation utilizes a generic wrapper for all functions. Hopefully it get's inlined.
```Zig
fn main() void {
    var runtimePolymorphism: ImplementingStruct = .{ .vtableTag = .A, ... }; 
    
    runtimePolymorphism.func1(.{ ... }); // Should execute Table.A.func1()!
    
    runtimePolymorphism.vtableTag = .B;
    
    runtimePolymorphism.func1(.{ ... }); // Should execute Table.B.func1()!
}
```

## The Future
Eventually I'll make it so you can also do. 
```Zig
const ImplementingUnion = union(VTable.TagType) {
    A: A,
    B: B,
    C: C
    ...
    const func1 = VTable.Fn("func1");
    const func2 = VTable.Fn("func2");
    ...
};

const ImplementingStruct = struct {
    vtableTag: union(VTable.TagType) { A: A, B: B, C: C, ... }, 
    unrelatedField: i32, // Just for show :)
    ...
    const func1 = VTable.Fn("func1");
    const func2 = VTable.Fn("func2");
    ...
};
```


