Red/System []

#include %common.reds
#include %memory.reds
#include %value.reds
#include %chunk.reds
#include %vm.reds
#include %debug.reds

rslox: context [
    
    vm-ctx/init

    chunk: declare chunk!

    main: func [
        /local
            constant [integer!]
    ][
        chunk-ctx/init chunk
        
        constant: chunk-ctx/add-constant chunk 1.2
        chunk-ctx/write chunk as byte! OP_CONSTANT 111  ;- 参数：chunk / byte字节码 / 行号
        chunk-ctx/write chunk as byte! constant 111

        constant: chunk-ctx/add-constant chunk 3.3
        chunk-ctx/write chunk as byte! OP_CONSTANT 111
        chunk-ctx/write chunk as byte! constant 111
        chunk-ctx/write chunk as byte! OP_RETURN 112

        disassemble-chunk chunk "test chunk"

        vm-ctx/interpret chunk
        vm-ctx/free

        chunk-ctx/free chunk
    ]
]

rslox/main

